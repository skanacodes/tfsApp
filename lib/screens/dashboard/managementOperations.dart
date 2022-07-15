// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tfsappv1/screens/ApprovalPermit/approvalPermit.dart';
import 'package:tfsappv1/services/constants.dart';

class ManagementOperation extends StatefulWidget {
  const ManagementOperation({Key? key}) : super(key: key);

  @override
  State<ManagementOperation> createState() => _ManagementOperationState();
}

class _ManagementOperationState extends State<ManagementOperation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
      child: Card(
        elevation: 10,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    "List Of Management Operations",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, ApprovalPermitt.routeName);
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(" Export Approval"),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.arrow_right,
                        color: kPrimaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(" Pending Inspection Request(s)"),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.arrow_right,
                      color: kPrimaryColor,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
