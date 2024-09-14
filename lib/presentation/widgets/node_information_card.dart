import 'package:flutter/material.dart';

import '../../localization/generated/l10n.dart';

class NodeInformationCard extends StatelessWidget {
  final Map<String, dynamic> nodeInfo;

  const NodeInformationCard({
    super.key,
    required this.nodeInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              S.current.NodeInformation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Colors.grey[500]!,
                width: 1,
              ),
            ),
            children: [
              const TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('#'),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('#'),
                    ),
                  ),
                ],
              ),
              if (nodeInfo['item']?['hardware'] != null) ...[
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('📟${S.current.Hardware}'),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(nodeInfo['item']?['hardware']),
                      ),
                    ),
                  ],
                ),
              ],
              if (nodeInfo['item']?['firmware'] != null) ...[
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('🔧${S.current.Firmware}'),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(nodeInfo['item']?['firmware']),
                      ),
                    ),
                  ],
                ),
              ],
              if (nodeInfo['item']?['role'] != null) ...[
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('🎭${S.current.Role}'),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(nodeInfo['item']?['role']),
                      ),
                    ),
                  ],
                ),
              ],
              if (nodeInfo['item']?['isLicensed'] != null) ...[
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('📜${S.current.IsLicensed}'),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text("${nodeInfo['item']?['isLicensed']}"),
                      ),
                    ),
                  ],
                ),
              ],
              if (nodeInfo['item']?['loraRegion'] != null) ...[
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('🌍${S.current.LoraRegion}'),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(nodeInfo['item']?['loraRegion']),
                      ),
                    ),
                  ],
                ),
              ],
              if (nodeInfo['item']?['loraModemPreset'] != null) ...[
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('📡${S.current.LoraModemPreset}'),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(nodeInfo['item']?['loraModemPreset']),
                      ),
                    ),
                  ],
                ),
              ],
              if (nodeInfo['item']?['hasDefaultChannel'] != null) ...[
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('📻${S.current.HasDefaultChannel}'),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child:
                            Text("${nodeInfo['item']?['hasDefaultChannel']}"),
                      ),
                    ),
                  ],
                ),
              ],
              if (nodeInfo['item']?['numOnlineLocalNodes'] != null) ...[
                TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('🕸️${S.current.NumOnlineLocalNodes}'),
                      ),
                    ),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child:
                            Text("${nodeInfo['item']?['numOnlineLocalNodes']}"),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
