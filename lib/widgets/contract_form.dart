import 'package:flutter/material.dart';
import '../models/contract.dart';
import 'package:intl/intl.dart';

class ContractForm extends StatefulWidget {
  final Function(Contract) onSave;
  final Contract? existingContract; // Add this parameter for editing
  final Function(Contract)? onDelete; // Add this parameter for deleting

  const ContractForm({
    Key? key,
    required this.onSave,
    this.existingContract, // Optional parameter for editing
    this.onDelete, // Optional parameter for deleting
  }) : super(key: key);

  @override
  State<ContractForm> createState() => _ContractFormState();
}

class _ContractFormState extends State<ContractForm> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  DateTime? _endDate; // Add this line for the project end date

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String _selectedState = '';
  final TextEditingController _zipController = TextEditingController();

  final Map<String, bool> _services = {
    'Painting': false,
    'Electrical': false,
    'Plumbing': false,
    'Carpentry': false,
    'Cleaning': false,
    'Landscaping': false,
    'Furniture': false,
    'Title': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final List<String> selectedServices = _services.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedServices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one service'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final contract = Contract(
        name: _nameController.text,
        email: _emailController.text,
        services: selectedServices,
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        endDate:
            _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : '',
        address: _addressController.text,
        city: _cityController.text,
        state: _selectedState,
        zipCode: _zipController.text,
      );

      widget.onSave(contract);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    // If we're editing an existing contract, populate the form fields
    if (widget.existingContract != null) {
      _nameController.text = widget.existingContract!.name;
      _emailController.text = widget.existingContract!.email;
      _addressController.text = widget.existingContract!.address;
      _cityController.text = widget.existingContract!.city;
      _selectedState = widget.existingContract!.state;
      _zipController.text = widget.existingContract!.zipCode;

      // Set the end date if it exists
      if (widget.existingContract!.endDate != null &&
          widget.existingContract!.endDate!.isNotEmpty) {
        try {
          _endDate =
              DateFormat('dd/MM/yyyy').parse(widget.existingContract!.endDate!);
        } catch (e) {
          // Handle parsing error
        }
      }
      // Set the selected services
      for (var service in widget.existingContract!.services) {
        if (_services.containsKey(service)) {
          _services[service] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        // Set a reasonable max height for the dialog
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        // Wrap the Form in a SingleChildScrollView to make it scrollable
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingContract == null
                          ? 'Create New Order'
                          : 'Edit Order',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Add delete button if we're editing an existing contract
                        if (widget.existingContract != null &&
                            widget.onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _showDeleteConfirmation,
                            tooltip: 'Delete Order',
                          ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _currentStep == 0
                              ? const Color(
                                  0xFF027DFF) // Blue background when selected
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                                0xFF027DFF), // Blue border for both tabs
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Property Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _currentStep == 0
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Add spacing between tabs
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _currentStep == 1
                              ? const Color(
                                  0xFF027DFF) // Blue background when selected
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(
                                0xFF027DFF), // Blue border for both tabs
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Property Services',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _currentStep == 1
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_currentStep == 0) ...[
                  const Text(
                    'Owner Name',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter property name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Owner Email',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Project Ending Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: TextEditingController(
                      text: _endDate != null
                          ? DateFormat('dd/MM/yyyy').format(_endDate!)
                          : '',
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != _endDate) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select project ending date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Property Address',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Street Address',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter street address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'City',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                hintText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter city';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'State',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: 'Select state',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: <String>[
                                'Alabama',
                                'Alaska',
                                'Arizona',
                                'California',
                                'Colorado',
                                'Florida',
                                'New York',
                                'Texas',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedState = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select state';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ZIP Code',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _zipController,
                    decoration: InputDecoration(
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ZIP code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _currentStep = 1;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF027DFF), // Changed to blue
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Continue to Services'),
                    ),
                  ),
                ],
                if (_currentStep == 1) ...[
                  // Remove the Expanded widget here
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Services',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey, // Changed to blue
                          ),
                        ),
                        const SizedBox(height: 6),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600
                                  ? 3
                                  : 2, // More columns on larger screens
                          childAspectRatio: 3.0,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: _services.keys.map((service) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: _services[service]!
                                      ? const Color(0xFF027DFF)
                                      : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  _showServiceDetails(service);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      4.0), // Reduced padding from 8.0
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _services[service],
                                            onChanged: (bool? value) {
                                              setState(() {
                                                _services[service] = value!;
                                              });
                                            },
                                          ),
                                          Expanded(
                                            child: Text(
                                              service,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 40.0),
                                        child: Text(
                                          'Tap for details',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentStep = 0;
                          });
                        },
                        child: const Text(
                            'Back'), // Add the child property with a Text widget
                      ),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF027DFF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          widget.existingContract == null
                              ? 'Create Order'
                              : 'Update Order',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(String service) {
    // Map of service descriptions
    final Map<String, String> serviceDescriptions = {
      'Painting': 'Interior and exterior painting services',
      'Electrical': 'Electrical repairs and installations',
      'Plumbing': 'Plumbing repairs and installations',
      'Carpentry': 'Carpentry and woodworking services',
      'Cleaning': 'Deep cleaning and maintenance',
      'Landscaping': 'Lawn care and landscaping services',
      'Furniture': 'Furniture assembly and repair',
      'Title': 'Title services and documentation',
    };

    // Map of service options for each service
    final Map<String, List<String>> serviceOptions = {
      'Painting': [
        'Interior Painting',
        'Exterior Painting',
        'Decorative Painting',
        'Cabinet Painting'
      ],
      'Electrical': [
        'Wiring',
        'Lighting Installation',
        'Electrical Repairs',
        'Panel Upgrades'
      ],
      'Plumbing': [
        'Pipe Repairs',
        'Fixture Installation',
        'Drain Cleaning',
        'Water Heater Services'
      ],
      'Carpentry': ['Custom Cabinets', 'Trim Work', 'Framing', 'Wood Repairs'],
      'Cleaning': [
        'Deep Cleaning',
        'Regular Maintenance',
        'Move-in/Move-out Cleaning',
        'Window Cleaning'
      ],
      'Landscaping': [
        'Lawn Mowing',
        'Garden Design',
        'Tree Trimming',
        'Irrigation'
      ],
      'Furniture': ['Assembly', 'Repair', 'Refinishing', 'Custom Building'],
      'Title': [
        'Title Search',
        'Title Insurance',
        'Document Preparation',
        'Closing Services'
      ],
    };

    // Create a map to track selected options
    Map<String, bool> options = {};
    for (var option in serviceOptions[service] ?? []) {
      options[option] = false;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$service Services',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      serviceDescriptions[service] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select specific services:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: serviceOptions[service]?.map((option) {
                              return CheckboxListTile(
                                title: Text(option),
                                value: options[option],
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    options[option] = value!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              );
                            }).toList() ??
                            [],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // If any option is selected, mark the main service as selected
                            bool anySelected =
                                options.values.any((selected) => selected);
                            if (anySelected) {
                              setState(() {
                                _services[service] = true;
                              });
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF027DFF),
                          ),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation() {
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
                if (widget.onDelete != null &&
                    widget.existingContract != null) {
                  widget.onDelete!(widget.existingContract!);
                  Navigator.pop(context); // Close the form dialog
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
