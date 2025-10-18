import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/client_model.dart';
import '../models/project_model.dart';
import '../models/invoice_model.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  // Storage keys
  static const String _clientsKey = 'clients';
  static const String _projectsKey = 'projects';
  static const String _invoicesKey = 'invoices';

  // Initialize the service
  Future<StorageService> init() async {
    _box = GetStorage();
    return this;
  }

  // ==================== CLIENT OPERATIONS ====================

  /// Save a new client to storage
  Future<void> saveClient(ClientModel client) async {
    final clients = getClients();

    // Check if client already exists
    final existingIndex = clients.indexWhere((c) => c.id == client.id);
    if (existingIndex != -1) {
      throw Exception('Client with id ${client.id} already exists. Use updateClient instead.');
    }

    clients.add(client);
    await _box.write(_clientsKey, clients.map((c) => c.toJson()).toList());
  }

  /// Get all clients from storage
  List<ClientModel> getClients() {
    final data = _box.read<List>(_clientsKey);
    if (data == null || data.isEmpty) return [];

    try {
      return data.map((json) => ClientModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error parsing clients: $e');
      return [];
    }
  }

  /// Get a single client by ID
  ClientModel? getClientById(String id) {
    final clients = getClients();
    try {
      return clients.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing client
  Future<void> updateClient(ClientModel client) async {
    final clients = getClients();
    final index = clients.indexWhere((c) => c.id == client.id);

    if (index == -1) {
      throw Exception('Client with id ${client.id} not found');
    }

    clients[index] = client;
    await _box.write(_clientsKey, clients.map((c) => c.toJson()).toList());
  }

  /// Delete a client by ID
  Future<void> deleteClient(String id) async {
    final clients = getClients();
    clients.removeWhere((c) => c.id == id);
    await _box.write(_clientsKey, clients.map((c) => c.toJson()).toList());

    // Also delete all projects associated with this client
    final projects = getProjects();
    final clientProjects = projects.where((p) => p.clientId == id).toList();
    for (var project in clientProjects) {
      await deleteProject(project.id);
    }
  }

  // ==================== PROJECT OPERATIONS ====================

  /// Save a new project to storage
  Future<void> saveProject(ProjectModel project) async {
    final projects = getProjects();

    // Check if project already exists
    final existingIndex = projects.indexWhere((p) => p.id == project.id);
    if (existingIndex != -1) {
      throw Exception('Project with id ${project.id} already exists. Use updateProject instead.');
    }

    projects.add(project);
    await _box.write(_projectsKey, projects.map((p) => p.toJson()).toList());
  }

  /// Get all projects from storage
  List<ProjectModel> getProjects() {
    final data = _box.read<List>(_projectsKey);
    if (data == null || data.isEmpty) return [];

    try {
      return data.map((json) => ProjectModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error parsing projects: $e');
      return [];
    }
  }

  /// Get all projects for a specific client
  List<ProjectModel> getProjectsByClientId(String clientId) {
    final projects = getProjects();
    return projects.where((p) => p.clientId == clientId).toList();
  }

  /// Get a single project by ID
  ProjectModel? getProjectById(String id) {
    final projects = getProjects();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing project
  Future<void> updateProject(ProjectModel project) async {
    final projects = getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);

    if (index == -1) {
      throw Exception('Project with id ${project.id} not found');
    }

    projects[index] = project;
    await _box.write(_projectsKey, projects.map((p) => p.toJson()).toList());
  }

  /// Delete a project by ID
  Future<void> deleteProject(String id) async {
    final projects = getProjects();
    projects.removeWhere((p) => p.id == id);
    await _box.write(_projectsKey, projects.map((p) => p.toJson()).toList());

    // Also delete all invoices associated with this project
    final invoices = getInvoices();
    invoices.removeWhere((i) => i.projectId == id);
    await _box.write(_invoicesKey, invoices.map((i) => i.toJson()).toList());
  }

  // ==================== INVOICE OPERATIONS ====================

  /// Save a new invoice to storage
  Future<void> saveInvoice(InvoiceModel invoice) async {
    final invoices = getInvoices();

    // Check if invoice already exists
    final existingIndex = invoices.indexWhere((i) => i.id == invoice.id);
    if (existingIndex != -1) {
      throw Exception('Invoice with id ${invoice.id} already exists. Use updateInvoice instead.');
    }

    invoices.add(invoice);
    await _box.write(_invoicesKey, invoices.map((i) => i.toJson()).toList());

    // Update the project's totalReceived if the invoice is paid
    if (invoice.status == 'paid') {
      await _updateProjectTotalReceived(invoice.projectId);
    }
  }

  /// Get all invoices from storage
  List<InvoiceModel> getInvoices() {
    final data = _box.read<List>(_invoicesKey);
    if (data == null || data.isEmpty) return [];

    try {
      return data.map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error parsing invoices: $e');
      return [];
    }
  }

  /// Get all invoices for a specific project
  List<InvoiceModel> getInvoicesByProjectId(String projectId) {
    final invoices = getInvoices();
    return invoices.where((i) => i.projectId == projectId).toList();
  }

  /// Get a single invoice by ID
  InvoiceModel? getInvoiceById(String id) {
    final invoices = getInvoices();
    try {
      return invoices.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing invoice
  Future<void> updateInvoice(InvoiceModel invoice) async {
    final invoices = getInvoices();
    final index = invoices.indexWhere((i) => i.id == invoice.id);

    if (index == -1) {
      throw Exception('Invoice with id ${invoice.id} not found');
    }

    invoices[index] = invoice;
    await _box.write(_invoicesKey, invoices.map((i) => i.toJson()).toList());

    // Update the project's totalReceived
    await _updateProjectTotalReceived(invoice.projectId);
  }

  /// Delete an invoice by ID
  Future<void> deleteInvoice(String id) async {
    final invoice = getInvoiceById(id);
    if (invoice == null) return;

    final invoices = getInvoices();
    invoices.removeWhere((i) => i.id == id);
    await _box.write(_invoicesKey, invoices.map((i) => i.toJson()).toList());

    // Update the project's totalReceived
    await _updateProjectTotalReceived(invoice.projectId);
  }

  // ==================== HELPER METHODS ====================

  /// Update a project's totalReceived based on its paid invoices
  Future<void> _updateProjectTotalReceived(String projectId) async {
    final project = getProjectById(projectId);
    if (project == null) return;

    final projectInvoices = getInvoicesByProjectId(projectId);
    final totalReceived = projectInvoices
        .where((i) => i.status == 'paid')
        .fold<double>(0.0, (sum, i) => sum + i.amount);

    final updatedProject = project.copyWith(totalReceived: totalReceived);
    await updateProject(updatedProject);
  }

  /// Get total received amount across all projects
  double getTotalReceivedAmount() {
    final projects = getProjects();
    return projects.fold<double>(0.0, (sum, p) => sum + p.totalReceived);
  }

  /// Get total budget across all projects
  double getTotalBudgetAmount() {
    final projects = getProjects();
    return projects.fold<double>(0.0, (sum, p) => sum + p.totalBudget);
  }

  /// Get total remaining amount across all projects
  double getTotalRemainingAmount() {
    return getTotalBudgetAmount() - getTotalReceivedAmount();
  }

  /// Clear all data from storage
  Future<void> clearAllData() async {
    await _box.remove(_clientsKey);
    await _box.remove(_projectsKey);
    await _box.remove(_invoicesKey);
  }

  /// Export all data as JSON
  Map<String, dynamic> exportData() {
    return {
      'clients': getClients().map((c) => c.toJson()).toList(),
      'projects': getProjects().map((p) => p.toJson()).toList(),
      'invoices': getInvoices().map((i) => i.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import data from JSON
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Import clients
      if (data.containsKey('clients')) {
        final clientsList = (data['clients'] as List)
            .map((json) => ClientModel.fromJson(json as Map<String, dynamic>))
            .toList();
        await _box.write(_clientsKey, clientsList.map((c) => c.toJson()).toList());
      }

      // Import projects
      if (data.containsKey('projects')) {
        final projectsList = (data['projects'] as List)
            .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
            .toList();
        await _box.write(_projectsKey, projectsList.map((p) => p.toJson()).toList());
      }

      // Import invoices
      if (data.containsKey('invoices')) {
        final invoicesList = (data['invoices'] as List)
            .map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>))
            .toList();
        await _box.write(_invoicesKey, invoicesList.map((i) => i.toJson()).toList());
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
