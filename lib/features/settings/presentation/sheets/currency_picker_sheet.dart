import 'package:dompet/features/settings/domain/currency_model.dart';
import 'package:dompet/features/settings/presentation/widgets/currency_search_list.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/shared/widgets/sheets/dompet_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

Future<CurrencyModel?> showCurrencyPickerSheet(
  BuildContext context,
  List<CurrencyModel> currencies,
  CurrencyModel? currentCurrency,
) async {
  return showDompetSheet<CurrencyModel>(
    context: context,
    builder: (context) => _CurrencyPickerSheet(
      currencies: currencies,
      currentCurrency: currentCurrency,
    ),
  );
}

class _CurrencyPickerSheet extends HookWidget {
  const _CurrencyPickerSheet({
    required this.currencies,
    this.currentCurrency,
  });

  final List<CurrencyModel> currencies;
  final CurrencyModel? currentCurrency;

  @override
  Widget build(BuildContext context) {
    return DompetSheet(
      title: t.settings.selectCurrency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: CurrencySearchList(
              currencies: currencies,
              selectedCurrency: currentCurrency,
              onSelect: (currency) {
                Navigator.of(context).pop(currency);
              },
            ),
          ),
        ],
      ),
    );
  }
}
