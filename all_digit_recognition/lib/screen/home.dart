import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Digit Recognizer'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 10,),
            Flexible(
              flex: 4,
              child: Container(
                color: Colors.black12,
                child: Container(
                  color: Colors.black26,
                  margin:const EdgeInsets.symmetric(horizontal:5,vertical: 10 ),
                  padding:const EdgeInsets.all(5),
                  child: Container(
                    color: Colors.black45,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Column(
                children: const [
                 Text("1",style: TextStyle(
                   fontSize: 60,
                   color: Colors.black,
                   fontWeight: FontWeight.bold,
                 ),),

                ],
              ),
            ),
          ],
        ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {  },
      child: const Icon(Icons.clear),
    ),);
  }
}
