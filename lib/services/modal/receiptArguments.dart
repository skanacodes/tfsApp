// ignore_for_file: file_names

class ReceiptScreenArguments {
  final String payerName;
  final String controlNumber;
  final String receiptNo;
  final double amount;
  final bool isBill;
  final String desc;
  final String issuer;
  final String? bankReceipt;
  final String? payedDate;
  final String? plotname;
  final String? station;
  final String? system;
  bool? isPrinted;
  final String? currency;
  final String? billId;
  final String? quantity;

  ReceiptScreenArguments(this.payerName, this.controlNumber, this.receiptNo,
      this.amount, this.isBill, this.desc, this.issuer,
      {this.bankReceipt,
      this.isPrinted,
      this.payedDate,
      this.quantity,
      this.system,
      this.billId,
      this.station,
      this.plotname,
      this.currency});
}
