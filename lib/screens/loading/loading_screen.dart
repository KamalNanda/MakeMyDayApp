 
import 'package:flutter/material.dart'; 

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  // void initState() { 
  //   super.initState();
  //   Timer(
  //     Duration(seconds: 5),
  //     () => Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //     ),
  //   );
  //   // print(ip.toString());
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: const Color(0xFF20232B),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 24,
            padding: EdgeInsets.only(bottom: 30),
 
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Center(
                    //   child: Text(
                    //     'Made with ❤️ by Kamal',
                    //     style: TextStyle(fontSize: 20, color: Colors.white),
                        
                    //   ),
                    // ),
                  ],
                ),
                Center(
                  child: Image.asset(
                    "assets/logo.png",
                    height: 240,
                    width: 240,
                  ),
                ),
              ],
            ) /* add child content here */,
          ), 
        ],
      ),
    );
  }
}
