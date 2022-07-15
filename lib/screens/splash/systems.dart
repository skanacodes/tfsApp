// ignore_for_file: library_private_types_in_public_api

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tfsappv1/screens/login/login.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:sizer/sizer.dart';

class SystemsList extends StatefulWidget {
  const SystemsList({Key? key}) : super(key: key);

  @override
  _SystemsListState createState() => _SystemsListState();
}

class _SystemsListState extends State<SystemsList> {
  List cardList = [const Item1(), const Item2(), const Item3(), const Item4()];
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  Widget _submitButton(
    icon,
    String text,
  ) {
    return InkWell(
      onTap: () async {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
        child: Container(
          height: 60,
          width: getProportionateScreenWidth(250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                    color: Colors.transparent,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [kPrimaryColor, Colors.green[50]!])),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: getProportionateScreenHeight(100),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Center(
                        child: icon,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 13.0.sp, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: getProportionateScreenHeight(20),
        ),
        Stack(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 600,
                pageSnapping: true,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: true,
                pauseAutoPlayOnManualNavigate: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                pauseAutoPlayOnTouch: true,
                onPageChanged: (index, reason) {
                  setState(() {});
                },
              ),
              items: cardList.map((card) {
                return Builder(builder: (BuildContext context) {
                  return SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Card(
                      color: Colors.white,
                      child: card,
                    ),
                  );
                });
              }).toList(),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                  height: getProportionateScreenHeight(500),
                  child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: AnimationLimiter(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    AnimationConfiguration.toStaggeredList(
                                        duration:
                                            const Duration(milliseconds: 1375),
                                        childAnimationBuilder: (widget) =>
                                            SlideAnimation(
                                              horizontalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: widget,
                                              ),
                                            ),
                                        children: <Widget>[
                                      _submitButton(const Icon(Icons.ac_unit),
                                          "Login With Fremis"),
                                      _submitButton(const Icon(Icons.nature_outlined),
                                          "Login With SeedMIS"),
                                      _submitButton(const Icon(Icons.beenhere),
                                          "Login With HoneyTraceability"),
                                      _submitButton(
                                          const Icon(Icons.nature), "Login With PMIS")
                                    ]))),
                      )))),
        ]),
      ],
    ));
  }
}

class Item1 extends StatelessWidget {
  const Item1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
              image: AssetImage(
                'assets/images/trees.jpg',
              ),
              fit: BoxFit.fill)),
    ));
  }
}

class Item2 extends StatelessWidget {
  const Item2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
              image: AssetImage(
                'assets/images/nyuki.jpg',
              ),
              fit: BoxFit.cover)),
    ));
  }
}

class Item3 extends StatelessWidget {
  const Item3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
              image: AssetImage(
                'assets/images/afzelia.jpg',
              ),
              fit: BoxFit.cover)),
    ));
  }
}

class Item4 extends StatelessWidget {
  const Item4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
              image: AssetImage(
                'assets/images/afzelia2.jpg',
              ),
              fit: BoxFit.cover)),
    ));
  }
}
