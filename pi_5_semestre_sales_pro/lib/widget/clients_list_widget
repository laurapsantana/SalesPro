import 'package:flutter/material.dart';
import '../api/api_service.dart';

class ClientsListWidget extends StatelessWidget {
  final List<ClienteMaisComprou> clientesMaisCompraram;

  const ClientsListWidget({Key? key, required this.clientesMaisCompraram}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clientesMaisCompraram.length,
      itemExtent: 70,
      itemBuilder: (context, index) {
        final cliente = clientesMaisCompraram[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              cliente.razaoCliente[0],
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
          title: Text(
            cliente.razaoCliente,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            "Compras: ${cliente.totalCompras.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white70),
          ),
        );
      },
    );
  }
}
