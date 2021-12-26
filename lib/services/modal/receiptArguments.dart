class ReceiptScreenArguments {
  final String payerName;
  final String controlNumber;
  final String receiptNo;
  final String amount;
  final bool isBill;
  final String desc;
  final String issuer;
  final String? bankReceipt;
  final String? payedDate;
  bool? isPrinted;

  ReceiptScreenArguments(this.payerName, this.controlNumber, this.receiptNo,
      this.amount, this.isBill, this.desc, this.issuer,
      {this.bankReceipt, this.isPrinted, this.payedDate});
}
