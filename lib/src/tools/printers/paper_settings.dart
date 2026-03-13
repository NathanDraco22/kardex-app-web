class TicketSettings {
  static double titleFontSize(PaperSize size) => size == PaperSize.mm58 ? 8.0 : 8.5;
  static double contentFontSize(PaperSize size) => size == PaperSize.mm58 ? 8.0 : 9.0;
  static double ticketWidth(PaperSize size) => size == PaperSize.mm58 ? 50.0 : 72.0;
  static double ticketMargin(PaperSize size) => size == PaperSize.mm58 ? 1.0 : 2.0;
  static double logoSize(PaperSize size) => size == PaperSize.mm58 ? 50.0 : 90.0;
}

enum PaperSize { mm58, mm80 }
