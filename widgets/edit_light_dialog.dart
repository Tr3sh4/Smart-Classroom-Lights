import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/light.dart';
import '../providers/light_provider.dart';

class EditLightDialog extends StatefulWidget {
  final Light light;

  const EditLightDialog({super.key, required this.light});

  @override
  State<EditLightDialog> createState() => _EditLightDialogState();
}

class _EditLightDialogState extends State<EditLightDialog> {
  late final TextEditingController nameController;
  late final TextEditingController roomController;
  late final TextEditingController ipController;
  late final TextEditingController pinController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.light.name);
    roomController = TextEditingController(text: widget.light.room);
    ipController = TextEditingController(text: widget.light.arduinoIp);
    pinController = TextEditingController(text: widget.light.pin.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    roomController.dispose();
    ipController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LightProvider>(context);

    return AlertDialog(
      title: const Text('Edit Light'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Light Name'),
          ),
          TextField(
            controller: roomController,
            decoration: const InputDecoration(labelText: 'Room'),
          ),
          TextField(
            controller: ipController,
            decoration: const InputDecoration(labelText: 'Arduino IP'),
          ),
          TextField(
            controller: pinController,
            decoration: const InputDecoration(labelText: 'GPIO Pin'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final pinValue = int.tryParse(pinController.text);
            if (pinValue == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid pin value')),
              );
              return;
            }

            final updated = Light(
              id: widget.light.id,
              name: nameController.text.trim(),
              room: roomController.text.trim(),
              arduinoIp: ipController.text.trim(),
              pin: pinValue,
              state: widget.light.state,
              dimLevel: widget.light.dimLevel,
            );

            await provider.updateLight(updated);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
