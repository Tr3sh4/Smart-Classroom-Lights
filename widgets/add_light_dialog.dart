import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/light.dart';
import '../providers/light_provider.dart';

class AddLightDialog extends StatefulWidget {
  const AddLightDialog({super.key});

  @override
  State<AddLightDialog> createState() => _AddLightDialogState();
}

class _AddLightDialogState extends State<AddLightDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController(text: 'Room 304');
  final _ipController = TextEditingController();
  final _pinController = TextEditingController();
  LightType? _lightType;
  bool _isAutoEnabled = true;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _roomController.addListener(_validateForm);
    _ipController.addListener(_validateForm);
    _pinController.addListener(_validateForm);
  }

  void _validateForm() {
    final provider = Provider.of<LightProvider>(context, listen: false);

    final nameOk = _nameController.text.trim().isNotEmpty;
    final roomOk = _roomController.text.trim().isNotEmpty;
    final ipOk = _ipController.text.trim().isNotEmpty;
    final pinStr = _pinController.text.trim();
    final pinNum = int.tryParse(pinStr);
    final pinOk = pinStr.isNotEmpty && pinNum != null && pinNum >= 0;
    final typeOk = _lightType != null;

    final allValid = nameOk && roomOk && ipOk && pinOk && typeOk;

    final proposedName = _nameController.text.trim().toLowerCase();
    final proposedRoom = _roomController.text.trim().toLowerCase();
    final hasDuplicate = provider.lights.any((l) =>
        l.name.toLowerCase() == proposedName &&
        l.room.toLowerCase() == proposedRoom);

    setState(() {
      _isValid = allValid && !hasDuplicate;
    });

    if (hasDuplicate && proposedName.isNotEmpty && proposedRoom.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Light already exists in room!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _ipController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.add_circle_outline, color: Colors.blue, size: 28),
          SizedBox(width: 12),
          Text(
            'Add Classroom Light',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: SizedBox(
        width: double.infinity,
        height: 450,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Light Name *',
                          hintText: 'Overhead 1',
                          prefixIcon: Icon(
                            Icons.lightbulb,
                            color: Colors.orange,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _roomController,
                        decoration: InputDecoration(
                          labelText: 'Room *',
                          hintText: 'Room 304',
                          prefixIcon: Icon(
                            Icons.meeting_room,
                            color: Colors.purple,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<LightType>(
                        initialValue: _lightType,
                        decoration: InputDecoration(
                          labelText: 'Type *',
                          prefixIcon: Icon(Icons.category, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: LightType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                type == LightType.overhead ? Icons.lightbulb : Icons.lightbulb_outline,
                                size: 20,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 8),
                              Text(type.toString().split('.').last.toUpperCase()),
                            ],
                          ),
                        )).toList(),
                        onChanged: (value) {
                          _lightType = value;
                          _validateForm();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ipController,
                        decoration: InputDecoration(
                          labelText: 'Arduino IP *',
                          hintText: '192.168.1.100',
                          prefixIcon: Icon(Icons.router),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value?.trim().isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pinController,
                        decoration: InputDecoration(
                          labelText: 'GPIO Pin *',
                          hintText: '13',
                          prefixIcon: Icon(Icons.pin_drop, color: Colors.red),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.trim().isEmpty == true) return 'Required';
                          final pin = int.tryParse(value!);
                          if (pin == null || pin < 0) return 'Valid pin';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('Auto Motion'),
                        subtitle: Text('Motion detection'),
                        value: _isAutoEnabled,
                        onChanged: (value) => setState(() => _isAutoEnabled = value),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isValid ? () async {
            final provider = Provider.of<LightProvider>(context, listen: false);
            final pinNum = int.parse(_pinController.text.trim());
            final newLight = Light(
              id: '',
              name: _nameController.text.trim(),
              room: _roomController.text.trim(),
              arduinoIp: _ipController.text.trim(),
              pin: pinNum,
              state: 'off',
              dimLevel: 50,
              lightType: _lightType,
              isAutoEnabled: _isAutoEnabled,
            );
            await provider.addLight(newLight);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added ${_nameController.text.trim()}!')),
            );
            Navigator.pop(context);
          } : null,
          icon: Icon(Icons.add),
          label: Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isValid ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
