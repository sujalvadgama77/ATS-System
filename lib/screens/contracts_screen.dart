import 'package:flutter/material.dart';
import '../models/contract.dart';
import '../widgets/contract_form.dart';
import '../screens/login_screen.dart';

class ContractsScreen extends StatefulWidget {
  final String userEmail;

  const ContractsScreen({
    Key? key,
    this.userEmail = 'admin@google.com',
  }) : super(key: key);

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  final List<Contract> _contracts = [];

  void _addContract(Contract contract) {
    setState(() {
      _contracts.add(contract);
    });
  }

  void _updateContract(Contract oldContract, Contract newContract) {
    setState(() {
      final index = _contracts.indexOf(oldContract);
      if (index != -1) {
        _contracts[index] = newContract;
      }
    });
  }

  void _showAddContractForm() {
    showDialog(
      context: context,
      builder: (context) => ContractForm(
        onSave: _addContract,
      ),
    );
  }

  void _showEditContractForm(Contract contract) {
    showDialog(
      context: context,
      builder: (context) => ContractForm(
        existingContract: contract,
        onSave: (newContract) {
          _updateContract(contract, newContract);
        },
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _confirmDeleteContract(Contract contract) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Order'),
          content: const Text(
              'Are you sure you want to delete this order? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
                _deleteContract(contract);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteContract(Contract contract) {
    setState(() {
      _contracts.removeWhere((c) => c.id == contract.id);
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF027DFF)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'Orders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF027DFF),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF027DFF),
              ),
              accountName: const Text('User Profile'),
              accountEmail: Text(widget.userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Color(0xFF027DFF),
                  size: 40,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF027DFF)),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _contracts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddContractForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF027DFF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '+   Create New Order',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _contracts.length,
                itemBuilder: (context, index) {
                  final contract = _contracts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: const Color(0xFF027DFF).withOpacity(0.3)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        contract.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        contract.services.join(', '),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            contract.date,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteContract(contract),
                            tooltip: 'Delete Order',
                          ),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF027DFF)),
                        ],
                      ),
                      onTap: () => _showEditContractForm(contract),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: _contracts.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddContractForm,
              backgroundColor: const Color(0xFF027DFF),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
