/// Shared enums for the Dompet transaction-detection pipeline.
///
/// Values are stored lowercase in the database to match the
/// EnumNameConverter convention used across the ledger schema.
library;

/// Type of a financial event detected from a notification.
enum DetectionTransactionType { income, expense, transfer }

/// Payment channel identified from a notification.
enum PaymentMethod { qris, bank, ewallet, card, cash, other }

/// Confidence tier assigned to a detected transaction.
enum ConfidenceTier { high, likely, uncertain, rejected }

/// Lifecycle state of a stored detection candidate.
enum DetectionStatus { pending, imported, ignored }
