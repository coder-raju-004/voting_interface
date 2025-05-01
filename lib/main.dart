import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Entry point of app
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voting App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();

  void login() {
    String username = usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VotingPage(username: username)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Welcome to Voting App',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Enter your username'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: login,
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Voting Page
class VotingPage extends StatefulWidget {
  final String username;
  const VotingPage({super.key, required this.username});
  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  Map<String, int> votes = {
    'Option A': 0,
    'Option B': 0,
    'Option C': 0,
  };
  bool hasVoted = false;
  String? votedOption;
  String roomName = 'Default Room';
  bool roomClosed = false;

  void vote(String option) {
    if (hasVoted || roomClosed) return;
    setState(() {
      votes[option] = votes[option]! + 1;
      hasVoted = true;
      votedOption = option;
    });
  }

  void resetVotes() {
    setState(() {
      votes.updateAll((key, value) => 0);
      hasVoted = false;
      votedOption = null;
      roomClosed = false;
    });
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void createNewRoom() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const CreateRoomPage()),
    );

    if (result != null && result.containsKey('roomName') && result.containsKey('options')) {
      Map<String, int> newVotes = {};
      for (var opt in result['options']) {
        newVotes[opt] = 0;
      }
      setState(() {
        roomName = result['roomName'];
        votes = newVotes;
        hasVoted = false;
        votedOption = null;
        roomClosed = false;
      });
    }
  }

  void closeRoom() {
    setState(() {
      roomClosed = true;
    });

    String winner = votes.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    int winnerVotes = votes[winner]!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Room Closed'),
        content: Text('Winner is **$winner** with $winnerVotes vote(s)!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$roomName - ${widget.username}'),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(roomClosed ? 'Voting Closed' : 'Vote for one option',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...votes.keys.map((option) {
              bool isWinner = roomClosed &&
                  option ==
                      votes.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: isWinner ? Colors.lightGreen.shade100 : null,
                child: ListTile(
                  title: Text(option,
                      style: TextStyle(
                          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                          color: isWinner ? Colors.green[900] : null)),
                  subtitle: Text('Votes: ${votes[option]}'),
                  trailing: ElevatedButton(
                    onPressed: roomClosed ? null : () => vote(option),
                    child: const Text('Vote'),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            if (hasVoted && !roomClosed)
              Text('You voted for: $votedOption',
                  style: const TextStyle(fontSize: 16, color: Colors.blue)),
            const Spacer(),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: resetVotes,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Votes'),
                ),
                ElevatedButton.icon(
                  onPressed: createNewRoom,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Room'),
                ),
                ElevatedButton.icon(
                  onPressed: roomClosed ? null : closeRoom,
                  icon: const Icon(Icons.lock),
                  label: const Text('Close Room'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Create New Room Page
class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});
  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController roomNameController = TextEditingController();
  final List<TextEditingController> optionControllers = [TextEditingController()];

  void addOptionField() {
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }

  void createRoom() {
    String roomName = roomNameController.text.trim();
    List<String> options = optionControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();

    if (roomName.isEmpty || options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter room name and at least 2 options')),
      );
      return;
    }

    Navigator.pop(context, {
      'roomName': roomName,
      'options': options,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Room')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: roomNameController,
              decoration: const InputDecoration(labelText: 'Room Name'),
            ),
            const SizedBox(height: 20),
            const Text('Voting Options:', style: TextStyle(fontSize: 16)),
            ...optionControllers.map((controller) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Option'),
                ),
              );
            }),
            TextButton.icon(
              onPressed: addOptionField,
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createRoom,
              child: const Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }
}