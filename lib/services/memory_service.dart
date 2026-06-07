import '../database/memory_database.dart';
import '../models/memory.dart';

class MemoryService {
  Future<List<Memory>> getAllMemories() async {
    return await MemoryDatabase.getAllMemories();
  }

  Future<int> addMemory(Memory memory) async {
    return await MemoryDatabase.insertMemory(memory);
  }

  Future<int> updateMemory(Memory memory) async {
    return await MemoryDatabase.updateMemory(memory);
  }

  Future<int> deleteMemory(int id) async {
    return await MemoryDatabase.deleteMemory(id);
  }
}