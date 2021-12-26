// import 'package:flutter/material.dart';
// import 'package:toggle_switch/toggle_switch.dart';

// class SeedBill extends StatefulWidget {
//   SeedBill({Key? key}) : super(key: key);

//   @override
//   _SeedBillState createState() => _SeedBillState();
// }

// class _SeedBillState extends State<SeedBill> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//      appBar: AppBar(
//         title: Text(
//           ' Generate Bill',
//           style: TextStyle(
//               color: Colors.black, fontFamily: 'ubuntu', fontSize: 17),
//         ),
//         backgroundColor: kPrimaryColor,
//       ),
//       body: ToggleSwitch(
//         minWidth: 90.0,
//         cornerRadius: 20.0,
//         inactiveFgColor: Colors.white,
//         initialLabelIndex: 1,
//         totalSwitches: 3,
//         labels: ['Normal', 'Bold', 'Italic'],
//         customTextStyles: [
//           null,
//           TextStyle(
//               color: Colors.brown, fontSize: 18.0, fontWeight: FontWeight.w900),
//           TextStyle(
//               color: Colors.black, fontSize: 16.0, fontStyle: FontStyle.italic)
//         ],
//         onToggle: (index) {
//           print('switched to: $index');
//         },
//       ),
//     );
//   }
// }
