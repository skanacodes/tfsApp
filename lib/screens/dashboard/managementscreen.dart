import 'package:flutter/material.dart';
import 'package:tfsappv1/screens/dashboard/chart.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({Key? key}) : super(key: key);

  @override
  _ManagementScreenState createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [Chart()],
    );
  }
}
