import 'package:flutter/material.dart';
import 'package:medi_master/pantallas/listado_pruebas.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de Pruebas"),
        centerTitle: true,
        //backgroundColor according to materialapp
        ),      
      body: ListadoPruebas(),
      // default theme and colors according to materialapp
      
    );
  }
}

