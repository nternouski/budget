// import 'package:budget/common/styles.dart';
// import 'package:budget/model/budget.dart';
// import 'package:budget/server/model_rx.dart';
// import 'package:flutter/material.dart';
// import '../common/color_constants.dart';

// const List budgetsJson = [
//   {"name": "Gift", "price": "\$2250.00", "label_percentage": "45%", "percentage": 0.45, "color": green},
//   {"name": "Automobile", "price": "\$3000.00", "label_percentage": "70%", "percentage": 0.7, "color": red},
//   {"name": "Bank", "price": "\$4000.00", "label_percentage": "90%", "percentage": 0.9, "color": blue}
// ];

// class BudgetsScreen extends StatefulWidget {
//   BudgetsScreen({Key? key}) : super(key: key);

//   @override
//   _BudgetsScreenState createState() => _BudgetsScreenState();
// }

// class _BudgetsScreenState extends State<BudgetsScreen> {
//   int activeDay = 3;
//   @override
//   Widget build(BuildContext context) {
//     budgetRx.getAll();
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//         slivers: getBody(),
//       ),
//     );
//   }

//   List<Widget> getBody() {
//     return [
//       SliverAppBar(
//         pinned: true,
//         backgroundColor: white,
//         leading: Padding(
//           padding: const EdgeInsets.only(top: 2),
//           child: IconButton(
//               icon: const Icon(Icons.menu, color: black), onPressed: () => Scaffold.of(context).openDrawer()),
//         ),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: const [Text("Budgets", style: titleStyle), Icon(Icons.search, color: black)],
//         ),
//       ),
//       StreamBuilder<List<Budget>>(
//         stream: budgetRx.fetchRx,
//         builder: (context, snapshot) {
//           if (snapshot.hasData && snapshot.data != null) {
//             final budgets = List<Budget>.from(snapshot.data!);
//             if (budgets.isEmpty) {
//               return SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: const [SizedBox(height: 60), Text('No budgets by the moment.', style: titleStyle)],
//                 ),
//               );
//             } else {
//               return SliverList(
//                 delegate: SliverChildBuilderDelegate((_, idx) => getBudget(budgets[idx]), childCount: budgets.length),
//               );
//             }
//           } else if (snapshot.hasError) {
//             return Text(snapshot.error.toString());
//           } else {
//             return const SliverToBoxAdapter(child: Text('Hubo un error inesperado en budgets_screen'));
//           }
//         },
//       ),
//     ];
//   }

//   getBudget(Budget budget) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20, right: 20),
//       child: Column(
//         children: List.generate(
//           budgetsJson.length,
//           (index) {
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 20),
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(12), boxShadow: [
//                   BoxShadow(
//                     color: grey.withOpacity(0.01),
//                     spreadRadius: 10,
//                     blurRadius: 3,
//                   ),
//                 ]),
//                 child: Padding(
//                   padding: EdgeInsets.only(left: 25, right: 25, bottom: 25, top: 25),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         budgetsJson[index]['name'],
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 13,
//                           color: Color(0xff67727d).withOpacity(0.6),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 budgetsJson[index]['price'],
//                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                               ),
//                               SizedBox(width: 8),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 3),
//                                 child: Text(
//                                   budgetsJson[index]['label_percentage'],
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 13,
//                                     color: Color(0xff67727d).withOpacity(0.6),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 3),
//                             child: Text(
//                               "\$5000.00",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 13,
//                                 color: Color(0xff67727d).withOpacity(0.6),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 15),
//                       Stack(
//                         children: [
//                           Container(
//                             width: (200 - 40),
//                             height: 4,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(5),
//                               color: Color(0xff67727d).withOpacity(0.1),
//                             ),
//                           ),
//                           Container(
//                             width: (200.0 - 40) * budgetsJson[index]['percentage'],
//                             height: 4,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(5),
//                               color: budgetsJson[index]['color'],
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../common/color_constants.dart';
import '../common/date.dart';

const List budgetsJson = [
  {"name": "Gift", "price": "\$2250.00", "label_percentage": "45%", "percentage": 0.45, "color": green},
  {"name": "Automobile", "price": "\$3000.00", "label_percentage": "70%", "percentage": 0.7, "color": red},
  {"name": "Bank", "price": "\$4000.00", "label_percentage": "90%", "percentage": 0.9, "color": blue}
];

class BudgetsScreen extends StatefulWidget {
  BudgetsScreen({Key? key}) : super(key: key);

  @override
  _BudgetsScreenState createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  int activeDay = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: getBody(),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: white,
              boxShadow: [
                BoxShadow(
                  color: grey.withOpacity(0.01),
                  spreadRadius: 10,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 60, right: 20, left: 20, bottom: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Budgets",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.add, size: 25),
                          SizedBox(width: 20),
                          Icon(Icons.search),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      months.length,
                      (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              activeDay = index;
                            });
                          },
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 40) / 6,
                            child: Column(
                              children: [
                                Text(months[index]['label'], style: TextStyle(fontSize: 10)),
                                SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                      color: activeDay == index ? primary : black.withOpacity(0.02),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: activeDay == index ? primary : black.withOpacity(0.1))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12, right: 12, top: 7, bottom: 7),
                                    child: Text(
                                      months[index]['day'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: activeDay == index ? white : black,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: List.generate(
                budgetsJson.length,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(12), boxShadow: [
                        BoxShadow(
                          color: grey.withOpacity(0.01),
                          spreadRadius: 10,
                          blurRadius: 3,
                        ),
                      ]),
                      child: Padding(
                        padding: EdgeInsets.only(left: 25, right: 25, bottom: 25, top: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budgetsJson[index]['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Color(0xff67727d).withOpacity(0.6),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      budgetsJson[index]['price'],
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                    ),
                                    SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        budgetsJson[index]['label_percentage'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: Color(0xff67727d).withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "\$5000.00",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Color(0xff67727d).withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Stack(
                              children: [
                                Container(
                                  width: (size.width - 40),
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Color(0xff67727d).withOpacity(0.1),
                                  ),
                                ),
                                Container(
                                  width: (size.width - 40) * budgetsJson[index]['percentage'],
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: budgetsJson[index]['color'],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
