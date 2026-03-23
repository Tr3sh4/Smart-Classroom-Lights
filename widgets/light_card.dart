import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/light.dart';
import '../providers/light_provider.dart';
import 'edit_light_dialog.dart';

class LightCard extends StatefulWidget {
  final Light light;

  const LightCard({super.key, required this.light});

  @override
  State<LightCard> createState() => _LightCardState();
}

class _LightCardState extends State<LightCard> {
  late double _currentDimLevel;

  @override
  void initState() {
    super.initState();
    _currentDimLevel = widget.light.dimLevel.toDouble();
  }

  @override
  void didUpdateWidget(covariant LightCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.light.dimLevel != widget.light.dimLevel) {
      _currentDimLevel = widget.light.dimLevel.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LightProvider>(context);
    debugPrint('Building LightCard for ${widget.light.name}');

    final isOn = widget.light.state == "on";
    final cardColor = isOn
        ? Colors.green.withAlpha(
            (25 + (widget.light.dimLevel / 100 * 50)).round(),
          )
        : Colors.red.withAlpha(25);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isOn ? Colors.green.withAlpha(77) : Colors.red.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.light.name,
              style: TextStyle(
                color: isOn ? Colors.green[800] : Colors.red[800],
              ),
            ),
            subtitle: Text('${widget.light.room} - ${widget.light.arduinoIp}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isOn,
                  onChanged: (_) => provider.toggleLight(widget.light),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => EditLightDialog(light: widget.light),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    provider.deleteLight(widget.light);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.light.name} deleted'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Slider(
            value: _currentDimLevel,
            min: 0,
            max: 100,
            divisions: 100,
            label: '${_currentDimLevel.toInt()}',
            onChanged: (val) {
              setState(() {
                _currentDimLevel = val;
              });
            },
            onChangeEnd: (val) {
              provider.setDim(widget.light, val.toInt());
            },
          ),
        ],
      ),
    );
  }
}
