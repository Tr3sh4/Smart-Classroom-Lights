import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/light_provider.dart';
import '../widgets/add_light_dialog.dart';
import '../widgets/light_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LightProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        title: const Text(
          'Classroom Lighting Control',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.selectedRoom,
                      isExpanded: true,
                      items: ['All Rooms', ...provider.uniqueRooms].map((
                        String room,
                      ) {
                        return DropdownMenuItem<String>(
                          value: room,
                          child: Text(room),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setSelectedRoom(value);
                        }
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      dropdownColor: const Color(0xFF1E88E5),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: provider.motionDetected
                          ? Colors.green
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          provider.motionDetected
                              ? Icons.sensors
                              : Icons.sensors_off,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.motionDetected
                              ? 'Motion Detected'
                              : 'No Motion',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Auto Mode'),
                          subtitle: Text('Motion detection & timer'),
                          value: provider.globalAutoMode,
                          onChanged: (_) => provider.toggleGlobalAutoMode(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _LightToggleButton(
                          title: 'Overhead Lights',
                          icon: Icons.lightbulb,
                          isOn: provider
                              .getOverheadLights(provider.selectedRoom)
                              .any((l) => l.state == 'on'),
                          onTap: () =>
                              provider.turnOffRoomLights(provider.selectedRoom),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _LightToggleButton(
                          title: 'Backlights',
                          icon: Icons.lightbulb_outline,
                          isOn: provider
                              .getBacklights(provider.selectedRoom)
                              .any((l) => l.state == 'on'),
                          onTap: () =>
                              provider.turnOffRoomLights(provider.selectedRoom),
                        ),
                      ),
                    ],
                  ),
                  if (provider.globalAutoMode) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text('${provider.currentSeconds}s remaining'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.electrical_services,
                              color: Colors.green,
                            ),
                            Text(
                              '${provider.energySaved.toStringAsFixed(1)} kWh',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Text(
                              'Energy Saved',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.attach_money, color: Colors.green),
                            Text(
                              '₱${provider.totalCostSaved.toStringAsFixed(1)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Text(
                              'Cost Saved',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.meeting_room, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.selectedRoom.isEmpty
                          ? 'All Rooms'
                          : provider.selectedRoom,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${provider.getRoomLights(provider.selectedRoom).length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (provider.loading)
              const Center(child: CircularProgressIndicator())
            else if (provider.getRoomLights(provider.selectedRoom).isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
                    Text('No lights in this room'),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.getRoomLights(provider.selectedRoom).length,
                itemBuilder: (context, index) {
                  final light = provider.getRoomLights(
                    provider.selectedRoom,
                  )[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: LightCard(light: light),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'motion',
            onPressed: provider.globalAutoMode ? provider.simulateMotion : null,
            backgroundColor: provider.globalAutoMode
                ? Colors.green
                : Colors.grey,
            icon: const Icon(Icons.sensors),
            label: const Text('Test Motion'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const AddLightDialog(),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _LightToggleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isOn;
  final VoidCallback onTap;

  const _LightToggleButton({
    required this.title,
    required this.icon,
    required this.isOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOn ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isOn ? Colors.green : Colors.red),
        ),
        child: Column(
          children: [
            Icon(icon, color: isOn ? Colors.green : Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
