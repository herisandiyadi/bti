import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return Container(
        height: MediaQuery.of(context).size.height * 0.09,
        width: MediaQuery.of(context).size.width,
        color: Colors.greenAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios,
                size: null,
              ),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.person),
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Arif Yusuf',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'last seen 15:27',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: const [
                  Icon(Icons.phone),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.more_vert)
                ],
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              header(),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.78,
              ),
              Container(
                color: Colors.greenAccent,
                height: MediaQuery.of(context).size.height * 0.12,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: const [
                          Icon(
                            Icons.image,
                            size: 36,
                          ),
                          Text('Gallery')
                        ],
                      ),
                      Column(
                        children: const [
                          Icon(
                            Icons.description,
                            size: 36,
                          ),
                          Text('Document')
                        ],
                      ),
                      Column(
                        children: const [
                          Icon(
                            Icons.room,
                            size: 36,
                          ),
                          Text('Gallery')
                        ],
                      ),
                      Column(
                        children: const [
                          Icon(
                            Icons.person,
                            size: 36,
                          ),
                          Text('Gallery')
                        ],
                      ),
                      Column(
                        children: const [
                          Icon(
                            Icons.play_arrow,
                            size: 36,
                          ),
                          Text('Gallery')
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
