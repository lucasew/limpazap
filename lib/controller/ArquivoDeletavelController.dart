import '../model/ArquivoDeletavelModel.dart';
import '../services/WhatsAppBackupService.dart';

class ArquivoDeletavelController {
  final WhatsAppBackupService _service = WhatsAppBackupService();
  bool inverter;
  bool exibirUltimo;
  ArquivoDeletavelController({this.inverter = false, this.exibirUltimo = false});

  Future<List<ArquivoDeletavel>> getArquivos() async {
    final allFiles = await _service.getBackupFiles();

    // Map files to the ArquivoDeletavel model, identifying old backups.
    final deletableFiles = allFiles
        .map((file) =>
            ArquivoDeletavel(file, isUltimo: !ArquivoDeletavel.regexBackup.hasMatch(file.path)))
        // If 'exibirUltimo' is false, filter out the most recent backup.
        .where(
            (file) => exibirUltimo || ArquivoDeletavel.regexBackup.hasMatch(file.arquivo.path))
        .toList();

    // Sort files by creation date.
    deletableFiles.sort((a, b) => a.dataCriacao.compareTo(b.dataCriacao));

    // Reverse the list if specified and return.
    return inverter ? deletableFiles.reversed.toList() : deletableFiles;
  }
}
