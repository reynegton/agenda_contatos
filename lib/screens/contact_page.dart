import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;
  bool _userEdited = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      nameController.text = _editedContact.name;
      emailController.text = _editedContact.email;
      phoneController.text = _editedContact.phone;
    }
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Descarga Alterações?'),
              content: Text('Se sair as alterações serão perdidas'),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancelar'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('Sim'),
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editedContact.name ?? 'Novo Contato'),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              if (_editedContact.name != null &&
                  _editedContact.name.isNotEmpty) {
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.camera).then(
                      (file) {
                        if (file == null) {
                          return;
                        } else {
                          setState(
                            () {
                              _editedContact.img = file.path;
                            },
                          );
                        }
                      },
                    );
                  },
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _editedContact.img != null
                            ? FileImage(File(_editedContact.img))
                            : AssetImage('assets/person.png'),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: 'Nome'),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = text;
                    });
                  },
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.email = text;
                  },
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Phone'),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                ),
              ],
            ),
          ),
        ),
        onWillPop: _requestPop);
  }
}
