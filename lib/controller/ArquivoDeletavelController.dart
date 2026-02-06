import '../model/ArquivoDeletavelModel.dart';
import '../services/WhatsAppBackupService.dart';

class ArquivoDeletavelController {
  final WhatsAppBackupService _service;
  bool inverter;
  bool exibirUltimo;

  ArquivoDeletavelController({
    WhatsAppBackupService? service,
    this.inverter = false,
    this.exibirUltimo = false,
  }) : _service = service ?? WhatsAppBackupService();

  Future<List<ArquivoDeletavel>> getArquivos() async {
    final allFiles = await _service.getBackupFiles();

    // Map files to the ArquivoDeletavel model asynchronously.
    final deletableFilesList = await Future.wait(
      allFiles.map(
        (file) => ArquivoDeletavel.load(
          file,
          isUltimo: !ArquivoDeletavel.regexBackup.hasMatch(file.path),
        ),
      ),
    );

    // Filter and sort.
    final deletableFiles = deletableFilesList
        .where(
          (file) =>
              exibirUltimo ||
              ArquivoDeletavel.regexBackup.hasMatch(file.arquivo.path),
        )
        .toList();

    // Sort files by creation date.
    deletableFiles.sort((a, b) => a.dataCriacao.compareTo(b.dataCriacao));

    // Reverse the list if specified and return.
    return inverter ? deletableFiles.reversed.toList() : deletableFiles;
  }
}
