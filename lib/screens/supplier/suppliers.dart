import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:stock_master/layout/appbar.dart';
import 'package:stock_master/layout/bottom_navigation_bar.dart';
import 'package:stock_master/layout/drawer.dart';
import 'package:stock_master/layout/handle_unauthorized_error.dart';
import 'package:stock_master/models/supplier.dart';
import 'package:stock_master/screens/supplier/create.dart';
import 'package:stock_master/screens/supplier/update.dart';
import 'package:stock_master/services/supplier.dart';

import 'package:url_launcher/url_launcher.dart';

class ShowSuppliers extends StatefulWidget {
  const ShowSuppliers({super.key});

  @override
  State<ShowSuppliers> createState() => _ShowSuppliersState();
}

class _ShowSuppliersState extends State<ShowSuppliers> {
  late List<Supplier> suppliers = [];

  SupplierServive supplierservice = SupplierServive();
  bool isLoading = true;

  allSuppliers() async {
    try {
      var response = await supplierservice.getAll();
      setState(() {
        suppliers = response;
        isLoading = false;
      });
    } on DioException catch (e) {
      print(e);
      if (e.response!.statusCode == 401) {
        handleUnauthorizedError(context);
      } else if (e.response != null) {
        print(e.response!.data);
      } else {
        print(e.message);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    allSuppliers();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Listes des fournisseurs"),
      drawer: const CustomAppDrawer(),
      bottomNavigationBar: const CustomBottomNavigationBar(index: 0),
      body: suppliers.isNotEmpty
          ? ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return Card(
            margin: const EdgeInsetsDirectional.all(5.0),
            child: ListTile(
              onTap: () => {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UpdateSupplier(supplier: supplier)))
              },
              leading: const Icon(Icons.person),
              title: Text(supplier.supplierName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      var phone = supplier.phone;
                      _launch('tel:$phone');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.email),
                    onPressed: () {
                      var email = supplier.email;
                      _launch('mailto:$email');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {
                      var phone = supplier.phone;
                      _launch('https://wa.me/$phone');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ) :  
      Center(
            child: isLoading 
              ? const CircularProgressIndicator(color: Colors.brown) 
              : const Text("Aucun fournisseur",style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CreateSupplier(),
          ));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Impossible de lancer l\'application téléphone';
    }
  }
}