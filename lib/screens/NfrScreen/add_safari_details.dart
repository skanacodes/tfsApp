import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:tfsappv1/screens/NfrScreen/activities_screen.dart';
import 'package:tfsappv1/screens/NfrScreen/camping_screen.dart';
import 'package:tfsappv1/screens/NfrScreen/film_screen.dart';
import 'package:tfsappv1/screens/NfrScreen/members_screen.dart';
import 'package:tfsappv1/screens/NfrScreen/permit.dart';
import 'package:tfsappv1/screens/NfrScreen/tour_guider.dart';
import 'package:tfsappv1/screens/NfrScreen/tourism_bill.dart';
import 'package:tfsappv1/screens/NfrScreen/vehicle_screen.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';

class AddSafariDetails extends StatefulWidget {
  static String routeName = "/safarisDetails";
  final List data;
  const AddSafariDetails({Key? key, required this.data}) : super(key: key);

  @override
  State<AddSafariDetails> createState() => _AddSafariDetailsState();
}

class _AddSafariDetailsState extends State<AddSafariDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: <Widget>[
            ExtendedSliverAppbar(
                // title: const Text(
                //   'ExtendedSliverAppbar',
                //   style: TextStyle(color: Colors.white),
                // ),
                toolBarColor: kPrimaryColor,
                isOpacityFadeWithTitle: true,
                leading: BackButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                ),
                background: SizedBox(
                  height: getProportionateScreenHeight(400),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: getProportionateScreenHeight(400),
                        child: Image.asset(
                          'assets/images/nature.jpeg',
                          // #Image Url: https://unsplash.com/photos/bOBM8CB4ZC4
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: getProportionateScreenHeight(400),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: getProportionateScreenHeight(100),
                              ),
                              const Text(
                                "Overview",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(10),
                              ),
                              ticketDetailsWidget(
                                  "Name",
                                  widget.data[0]["group_name"].toString() ==
                                          "null"
                                      ? widget.data[0]["leader_name"].toString()
                                      : widget.data[0]["group_name"].toString(),
                                  "No. Of Tourist",
                                  widget.data[0]["no_of_tourist"].toString()),
                              ticketDetailsWidget(
                                  "Start Date",
                                  widget.data[0]["safari_start_date"]
                                      .toString(),
                                  "End Date",
                                  widget.data[0]["safari_end_date"].toString()),
                              ticketDetailsWidget(
                                  "description",
                                  widget.data[0]["description".toString()],
                                  "Phone No",
                                  widget.data[0]["phone_no"].toString())
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PermittScreen(
                                      id: widget.data[0]["id"].toString(),
                                    )),
                          );
                        }),
                        child: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TourismBillScreen(
                                      id: widget.data[0]["id"].toString(),
                                    )),
                          );
                        }),
                        child: const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.payment_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return InkWell(
                    onTap: (() {
                      index == 0
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MemberScreen(
                                        id: widget.data[0]["id"].toString(),
                                      )),
                            )
                          : index == 1
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CampingScreen(
                                            id: widget.data[0]["id"].toString(),
                                          )),
                                )
                              : index == 2
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => VehicleScreen(
                                                id: widget.data[0]["id"]
                                                    .toString(),
                                              )),
                                    )
                                  : index == 3
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ActivitiesScreen(
                                                    id: widget.data[0]["id"]
                                                        .toString(),
                                                  )),
                                        )
                                      : index == 4
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TourGuiderScreen(
                                                        id: widget.data[0]["id"]
                                                            .toString(),
                                                      )),
                                            )
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FilmingScreen(
                                                        id: widget.data[0]["id"]
                                                            .toString(),
                                                      )));
                    }),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 2),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ]),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Row(children: [
                                    SizedBox(
                                        width: 20,
                                        height:
                                            getProportionateScreenHeight(40),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: IntrinsicHeight(
                                              child: SizedBox(
                                                  height: double.maxFinite,
                                                  width:
                                                      getProportionateScreenHeight(
                                                          50),
                                                  child: Row(
                                                    children: [
                                                      VerticalDivider(
                                                        color: index.isEven
                                                            ? kPrimaryColor
                                                            : Colors.green[200],
                                                        thickness: 5,
                                                      )
                                                    ],
                                                  ))),
                                        )),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      flex: 4,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            index == 0
                                                ? Text("Entrace Fees ",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w500))
                                                : index == 1
                                                    ? Text("Camping ",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))
                                                    : index == 2
                                                        ? Text("Vehicle ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500))
                                                        : index == 3
                                                            ? Text("Activities ",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        10.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500))
                                                            : index == 4
                                                                ? Text(
                                                                    "Tour Guiders ",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            10.sp,
                                                                        fontWeight: FontWeight.w500))
                                                                : Text("Commercial Filming ", style: TextStyle(color: Colors.black, fontSize: 10.sp, fontWeight: FontWeight.w500)),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            index == 0
                                                ? Text("Add Members of Safari",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[500]))
                                                : index == 1
                                                    ? Text("Add Camping Details",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[500]))
                                                    : index == 2
                                                        ? Text(
                                                            "Add Vehicles Details",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[500]))
                                                        : index == 3
                                                            ? Text(
                                                                "Add Tourist Activities",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .grey[
                                                                        500]))
                                                            : index == 4
                                                                ? Text(
                                                                    "Add Tour Guiders Details ",
                                                                    style: TextStyle(
                                                                        color:
                                                                            Colors.grey[500]))
                                                                : Text("Add Commercial Filming Details ", style: TextStyle(color: Colors.grey[500])),
                                          ]),
                                    )
                                  ]),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ticketDetailsWidget(String firstTitle, String firstDesc,
      String secondTitle, String secondDesc) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  firstTitle,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Text(
                    firstDesc,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  secondTitle,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Text(
                    secondDesc,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
