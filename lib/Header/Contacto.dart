import 'package:flutter/material.dart';

class ContactoScreen extends StatefulWidget {
  @override
  _ContactoScreenState createState() => _ContactoScreenState();
}

class _ContactoScreenState extends State<ContactoScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _asuntoController = TextEditingController();
  final _mensajeController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _asuntoController.dispose();
    _mensajeController.dispose();
    late AnimationController _controller;
    late Animation<double> _animation;

    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
      _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );
      _controller.repeat(reverse: true);
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacto'),
        backgroundColor: Color(0xFF060D17),
      ),
      body: Center(child: Text('Formulario de contacto aquí')),
    );
  }
}
