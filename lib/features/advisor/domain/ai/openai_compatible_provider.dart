/// OpenAI-compatible AI provider for external AI services.
library;

import 'dart:convert';

import 'package:dompet/features/advisor/domain/ai/ai_provider.dart';
import 'package:http/http.dart' as http;

/// Configuration for an OpenAI-compatible API provider.
class OpenAICompatibleConfig {
  const OpenAICompatibleConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.timeout = const Duration(seconds: 30),
  });

  /// Base URL of the API (e.g., "https://api.openai.com/v1" or "http://localhost:11434/v1")
  final String baseUrl;

  /// API key for authentication.
  final String apiKey;

  /// Model identifier (e.g., "gpt-4", "llama3", "mistral").
  final String model;

  /// Temperature for response randomness (0.0 to 2.0).
  final double temperature;

  /// Maximum tokens in response.
  final int maxTokens;

  /// Request timeout.
  final Duration timeout;
}

/// OpenAI-compatible AI provider.
class OpenAICompatibleProvider implements AdvisorProvider {
  OpenAICompatibleProvider({
    required this._config,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final OpenAICompatibleConfig _config;
  final http.Client _client;

  @override
  String get id => 'openai-compatible';

  @override
  String get name => 'OpenAI Compatible (${_config.model})';

  @override
  bool get requiresApiKey => true;

  @override
  Future<AdvisorResponse> analyze(AdvisorContext context) async {
    final prompt = _buildAnalysisPrompt(context);
    final response = await _chatCompletion([
      {'role': 'system', 'content': _systemPrompt()},
      {'role': 'user', 'content': prompt},
    ]);

    return _parseAdvisorResponse(response);
  }

  @override
  Future<String> explainTransaction(TransactionContext context) async {
    final prompt = _buildTransactionPrompt(context);
    final response = await _chatCompletion([
      {'role': 'system', 'content': _systemPrompt()},
      {'role': 'user', 'content': prompt},
    ]);
    return response;
  }

  @override
  Future<String> summarizeMonth(MonthlySummaryContext context) async {
    final prompt = _buildMonthlySummaryPrompt(context);
    return _chatCompletion([
      {'role': 'system', 'content': _systemPrompt()},
      {'role': 'user', 'content': prompt},
    ]);
  }

  @override
  Future<BudgetPlanResponse> generateBudgetPlan(BudgetContext context) async {
    final prompt = _buildBudgetPrompt(context);
    final response = await _chatCompletion([
      {'role': 'system', 'content': _systemPrompt()},
      {'role': 'user', 'content': prompt},
    ]);
    return _parseBudgetResponse(response);
  }

  @override
  Future<CashFlowAnalysisResponse> analyzeCashFlow(CashFlowContext context) async {
    final prompt = _buildCashFlowPrompt(context);
    final response = await _chatCompletion([
      {'role': 'system', 'content': _systemPrompt()},
      {'role': 'user', 'content': prompt},
    ]);
    return _parseCashFlowResponse(response);
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${_config.baseUrl}/models'),
            headers: {'Authorization': 'Bearer ${_config.apiKey}'},
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  String _systemPrompt() {
    return '''
You are Dompet Advisor, a personal finance AI assistant.
Provide clear, actionable financial advice in Indonesian.
Be concise, practical, and respectful of user privacy.
Respond in Indonesian language with amounts in IDR format (e.g., Rp1.500.000).''';
  }

  String _buildAnalysisPrompt(AdvisorContext context) {
    final buffer = StringBuffer()
      ..writeln('Analyze this financial situation and provide recommendations:')
      ..writeln()
      ..writeln('Income: ${_formatAmount(context.incomeSummary.total)}')
      ..writeln('Expenses: ${_formatAmount(context.expenseSummary.total)}')
      ..writeln('Net: ${_formatAmount(context.incomeSummary.total - context.expenseSummary.total)}')
      ..writeln()
      ..writeln('Budget Status:');
    for (final budget in context.budgetSummary.budgets) {
      final pct = (budget.spent / budget.amount * 100).toStringAsFixed(0);
      buffer.writeln('  ${budget.name}: ${_formatAmount(budget.spent)}/${_formatAmount(budget.amount)} ($pct%)');
    }
    buffer
      ..writeln()
      ..writeln('Recent Transactions:');
    for (final t in context.recentTransactions.take(5)) {
      buffer.writeln('  ${t.date.day}/${t.date.month} ${t.type.name} ${_formatAmount(t.amount)} ${t.merchant ?? ""}');
    }
    buffer
      ..writeln()
      ..writeln('Provide 3-5 actionable recommendations in Indonesian.');
    return buffer.toString();
  }

  String _buildTransactionPrompt(TransactionContext context) {
    return 'Jelaskan transaksi ini: ${context.transaction.type.name} ${_formatAmount(context.transaction.amount)} '
        'di ${context.transaction.merchant ?? "merchant tidak diketahui"} '
        'kategori ${context.categoryName}.';
  }

  String _buildMonthlySummaryPrompt(MonthlySummaryContext context) {
    return 'Ringkasan keuangan bulan ${context.month.month}/${context.month.year}: '
        'Pemasukan ${_formatAmount(context.income)}, '
        'Pengeluaran ${_formatAmount(context.expenses)}, '
        'Tabungan ${_formatAmount(context.savings)}. '
        'Berikan ringkasan singkat dalam Bahasa Indonesia.';
  }

  String _buildBudgetPrompt(BudgetContext context) {
    return 'Buat rencana anggaran untuk pendapatan ${_formatAmount(context.income)}: '
        'Pengeluaran tetap ${context.fixedExpenses.values.fold(0, (a, b) => a + b)}, '
        'Pengeluaran variabel ${context.variableExpenses.values.fold(0, (a, b) => a + b)}.';
  }

  String _buildCashFlowPrompt(CashFlowContext context) {
    return 'Analisis arus kas: Pendapatan bulanan ${_formatAmount(context.monthlyIncome)}, '
        'Pengeluaran bulanan ${_formatAmount(context.monthlyExpenses)}. '
        'Berikan analisis tren arus kas.';
  }

  String _formatAmount(int amount) {
    final sign = amount < 0 ? '-' : '';
    final abs = amount.abs();
    return '$sign Rp${abs.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<String> _chatCompletion(List<Map<String, String>> messages) async {
    final uri = Uri.parse('${_config.baseUrl}/chat/completions');
    final body = jsonEncode({
      'model': _config.model,
      'messages': messages,
      'temperature': _config.temperature,
      'max_tokens': _config.maxTokens,
    });

    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_config.apiKey}',
          },
          body: body,
        )
        .timeout(_config.timeout);

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] as String;
  }

  AdvisorResponse _parseAdvisorResponse(String response) {
    // Simple parsing - in production use structured output
    return AdvisorResponse(
      recommendations: [
        AdvisorRecommendation(
          type: 'ai_analysis',
          severity: AISeverity.info,
          title: 'AI Analysis',
          message: response,
        ),
      ],
    );
  }

  BudgetPlanResponse _parseBudgetResponse(String response) {
    return BudgetPlanResponse(allocations: {}, notes: response);
  }

  CashFlowAnalysisResponse _parseCashFlowResponse(String response) {
    return CashFlowAnalysisResponse(summary: response);
  }
}
