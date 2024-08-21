import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isChatTextBoxVisible = false;
  bool _isFloatingChatButtonVisible = false;

  @override
  void initState() {
    super.initState();

    // Start a 5-second timer to show both the chat box and floating chat button
    Timer(Duration(seconds: 5), () {
      setState(() {
        _isChatTextBoxVisible = true;
        _isFloatingChatButtonVisible = true;
      });

      // After showing the chat box, start another timer to hide only the chat box after 5 seconds
      Timer(Duration(seconds: 5), () {
        setState(() {
          _isChatTextBoxVisible = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('AI ChatBot'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'lib/assets/images.jpeg', // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceCard(context),
                SizedBox(height: 20),
                _buildGridOptions(),
                SizedBox(height: 20),
                _buildCarouselSlider(), // Carousel slider in the red section
              ],
            ),
          ),
          if (_isChatTextBoxVisible)
            Positioned(
              bottom: 70.0, // Adjust this value to control the distance above the FAB
              right: 20.0,
              child: _buildChatTextBox(),
            ),
          if (_isFloatingChatButtonVisible)
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: _buildFloatingChatButton(),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFloatingChatButton() {
  return FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen()),
      );
    },
    child: Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'lib/assets/chat_icon.png', // Replace with your image path
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}

  Widget _buildCarouselSlider() {
    final List<String> carouselImages = [
      'lib/assets/slider1.jpg', // Replace with your image paths
      'lib/assets/slider1.jpg',
      'lib/assets/slider1.jpg',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 150.0, // Adjust height based on your design
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
      ),
      items: carouselImages.map((imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildServiceCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(),
          SizedBox(height: 8),
          Text(
            '640.93',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          Divider(height: 20, color: Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPointsSection(
                  '3BB Points', '203', Colors.orange, Colors.orange.shade100),
              _buildPointsSection(
                  'AIS Points', '0', Colors.green, Colors.green.shade100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ยอดค่าใช้บริการ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'ชำระค่าบริการ',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSection(String title, String points, Color buttonColor,
      Color buttonBackgroundColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        SizedBox(height: 4),
        Text(
          points,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: buttonColor,
          ),
        ),
        SizedBox(height: 4),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'แลกพอยท์',
            style: TextStyle(color: buttonColor, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildGridOptions() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
        children: [
          _buildIconButton('ชำระค่า', Icons.payment),
          _buildIconButton('เช็คเน็ต', Icons.network_check),
          _buildIconButton('สิทธิพิเศษ', Icons.card_giftcard),
          _buildIconButton('แลกพอยท์', Icons.redeem),
          _buildIconButton('Fibre3', Icons.router),
          _buildIconButton('3BB GIGATV', Icons.tv),
          _buildIconButton('MONO MAX', Icons.video_library),
          _buildIconButton('AIS PLAY', Icons.play_arrow),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'หน้าหลัก',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'ประวัติ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help),
          label: 'ช่วยเหลือ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'แจ้งเตือน',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'ฉัน',
        ),
      ],
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.white,
      backgroundColor: Colors.black,
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget _buildChatTextBox() {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'สวัสดีค่ะลูกค้าที่น่ารัก! \nสนใจแพ็กเกจไหนเป็นพิเศษมั้ยคะ? 😊',
        style: TextStyle(
          fontSize: 8,
          color: Colors.grey[900],
        ),
      ),
    );
  }

  Widget _buildIconButton(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
