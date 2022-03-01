import 'package:flutter/material.dart';

class SubjectRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text("Grade.ly"),
            floating: false,
            pinned: true,
            expandedHeight: 150,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        height: 54,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Text(
                                    "aaaaaa",
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: const [
                                  Text(
                                    "01",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(right: 24)),
                                  Icon(
                                    Icons.navigate_next,
                                    size: 24.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
              // Builds 1000 ListTiles
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
