import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/screens/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOption { orderaz, orderza }

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void getAllContacts() {
    helper.getAllContact().then(
      (value) {
        setState(
          () {
            contacts = value;
            print(contacts);
          },
        );
      },
    );
  }

  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contact,
        ),
      ),
    );
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      getAllContacts();
    }
  }

  void _showOptions(BuildContext context, int index) {
    showBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: () {
                        launch('tel:${contacts[index].phone}');
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Ligar',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(
                          contact: contacts[index],
                        );
                      },
                      child: Text(
                        'Editar',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          helper.deleteContact(contacts[index].id);
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                      child: Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null
                        ? FileImage(File(contacts[index].img))
                        : AssetImage('assets/person.png'),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].name ?? '',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? '',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      contacts[index].phone ?? '',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getAllContacts();
  }

  void _orderList(OrderOption result) {
    switch (result) {
      case OrderOption.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOption.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<OrderOption>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOption>>[
              const PopupMenuItem<OrderOption>(
                child: Text('Ordernar de A-Z'),
                value: OrderOption.orderaz,
              ),
              const PopupMenuItem<OrderOption>(
                child: Text('Ordernar de Z-A'),
                value: OrderOption.orderza,
              )
            ],
            onSelected: _orderList,
          ),
        ],
        title: Text('Agenda'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }
}
