import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _base64Image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendMessage('สวัสดี', showInChat: false); // Initial request to BroadBand API
  }

  void _sendMessage(String message, {bool showInChat = true}) async {
    if (message.isEmpty && _base64Image == null) return;

    setState(() {
      _isLoading = true;
    });

    if (_base64Image != null) {
      final imageMessage = {
        'sender': 'user',
        'message': 'image',
        'imagePath': _selectedImage!.path,
      };
      setState(() {
        _messages.add(imageMessage);
        _selectedImage = null;
      });
      _controller.clear();

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/process_base64_image'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'image_base64': _base64Image!,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final processedImageBase64 = responseBody['processed_image_base64'];
          final analysisSummary = responseBody['analysis_summary'];
          final wifiRecommendation = responseBody['wifi_recommendation'];

          setState(() {
            _messages.add({'sender': 'bot', 'message': 'image', 'imageBase64': processedImageBase64});
            _messages.add({'sender': 'bot', 'message': 'Analysis Summary: $analysisSummary'});
            _messages.add({'sender': 'bot', 'message': 'Wi-Fi Recommendation: $wifiRecommendation'});
          });
        } else {
          setState(() {
            _messages.add({'sender': 'bot', 'message': 'Failed to process image'});
          });
        }
      } catch (e) {
        setState(() {
          _messages.add({'sender': 'bot', 'message': 'Error: $e'});
        });
      } finally {
        _base64Image = null;
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (showInChat) {
        setState(() {
          _messages.add({'sender': 'user', 'message': message});
        });
      }

      _controller.clear();

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/BroadBand'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'message': message,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _messages.add({'sender': 'bot', 'message': jsonDecode(response.body)['response']});
          });
        } else {
          setState(() {
            _messages.add({'sender': 'bot', 'message': 'Failed to fetch response'});
          });
        }
      } catch (e) {
        setState(() {
          _messages.add({'sender': 'bot', 'message': 'Error: $e'});
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Image = base64Image;
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _selectedImage = File(pickedFile.path);
        _base64Image = base64Image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['sender'] == 'user';
                bool isImage = message['message'] == 'image';

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          child: Icon(Icons.person, color: Colors.white),
                          backgroundColor: Colors.grey,
                          radius: 15,
                        ),
                      if (!isUser)
                        SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isUser
                                  ? [Colors.orange, Colors.pink]
                                  : [Colors.blue, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                              bottomLeft: isUser ? Radius.circular(15.0) : Radius.zero,
                              bottomRight: isUser ? Radius.zero : Radius.circular(15.0),
                            ),
                          ),
                          child: isImage
                              ? (message['imagePath'] != null
                                  ? Image.file(File(message['imagePath']!))
                                  : message['imageBase64'] != null
                                      ? Image.memory(base64Decode(message['imageBase64']!))
                                      : Container())
                              : Text(
                                  message['message']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      if (isUser)
                        SizedBox(width: 10),
                      if (isUser)
                        CircleAvatar(
                          child: Icon(Icons.person, color: Colors.white),
                          backgroundColor: Colors.blue,
                          radius: 15,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 20.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.orange),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.orange),
                  onPressed: _takePhoto,
                ),
                Expanded(
                  child: _selectedImage == null
                      ? TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[800],
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                          ),
                          style: TextStyle(color: Colors.white),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(_selectedImage!),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _base64Image = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.orange,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      _sendMessage(_controller.text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}