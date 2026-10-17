import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';

const _r1 = 'Region I (Ilocos Region)';
const _r2 = 'Region II (Cagayan Valley)';
const _r3 = 'Region III (Central Luzon)';
const _r4a = 'Region IV-A (CALABARZON)';
const _mimaropa = 'MIMAROPA Region';
const _r5 = 'Region V (Bicol Region)';
const _r6 = 'Region VI (Western Visayas)';
const _r7 = 'Region VII (Central Visayas)';
const _r8 = 'Region VIII (Eastern Visayas)';
const _r9 = 'Region IX (Zamboanga Peninsula)';
const _r10 = 'Region X (Northern Mindanao)';
const _r11 = 'Region XI (Davao Region)';
const _r12 = 'Region XII (SOCCSKSARGEN)';
const _car = 'Cordillera Administrative Region (CAR)';
const _r13 = 'Region XIII (Caraga)';
const _barmm = 'Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)';

PsgcAddressOption _p(String code, String name, String region) =>
    PsgcAddressOption(code: code, name: name, region: region);

final List<PsgcAddressOption> psgcFallbackProvinces = List.unmodifiable([
  _p('0102800000', 'Ilocos Norte', _r1),
  _p('0102900000', 'Ilocos Sur', _r1),
  _p('0103300000', 'La Union', _r1),
  _p('0105500000', 'Pangasinan', _r1),
  _p('0200900000', 'Batanes', _r2),
  _p('0201500000', 'Cagayan', _r2),
  _p('0203100000', 'Isabela', _r2),
  _p('0205000000', 'Nueva Vizcaya', _r2),
  _p('0205700000', 'Quirino', _r2),
  _p('0300800000', 'Bataan', _r3),
  _p('0301400000', 'Bulacan', _r3),
  _p('0304900000', 'Nueva Ecija', _r3),
  _p('0305400000', 'Pampanga', _r3),
  _p('0306900000', 'Tarlac', _r3),
  _p('0307100000', 'Zambales', _r3),
  _p('0307700000', 'Aurora', _r3),
  _p('0401000000', 'Batangas', _r4a),
  _p('0402100000', 'Cavite', _r4a),
  _p('0403400000', 'Laguna', _r4a),
  _p('0405600000', 'Quezon', _r4a),
  _p('0405800000', 'Rizal', _r4a),
  _p('1704000000', 'Marinduque', _mimaropa),
  _p('1705100000', 'Occidental Mindoro', _mimaropa),
  _p('1705200000', 'Oriental Mindoro', _mimaropa),
  _p('1705300000', 'Palawan', _mimaropa),
  _p('1705900000', 'Romblon', _mimaropa),
  _p('0500500000', 'Albay', _r5),
  _p('0501600000', 'Camarines Norte', _r5),
  _p('0501700000', 'Camarines Sur', _r5),
  _p('0502000000', 'Catanduanes', _r5),
  _p('0504100000', 'Masbate', _r5),
  _p('0506200000', 'Sorsogon', _r5),
  _p('0600400000', 'Aklan', _r6),
  _p('0600600000', 'Antique', _r6),
  _p('0601900000', 'Capiz', _r6),
  _p('0603000000', 'Iloilo', _r6),
  _p('0604500000', 'Negros Occidental', _r6),
  _p('0607900000', 'Guimaras', _r6),
  _p('0701200000', 'Bohol', _r7),
  _p('0702200000', 'Cebu', _r7),
  _p('0704600000', 'Negros Oriental', _r7),
  _p('0706100000', 'Siquijor', _r7),
  _p('0802600000', 'Eastern Samar', _r8),
  _p('0803700000', 'Leyte', _r8),
  _p('0804800000', 'Northern Samar', _r8),
  _p('0806000000', 'Samar', _r8),
  _p('0806400000', 'Southern Leyte', _r8),
  _p('0807800000', 'Biliran', _r8),
  _p('0907200000', 'Zamboanga del Norte', _r9),
  _p('0907300000', 'Zamboanga del Sur', _r9),
  _p('0908300000', 'Zamboanga Sibugay', _r9),
  _p('1001300000', 'Bukidnon', _r10),
  _p('1001800000', 'Camiguin', _r10),
  _p('1003500000', 'Lanao del Norte', _r10),
  _p('1004200000', 'Misamis Occidental', _r10),
  _p('1004300000', 'Misamis Oriental', _r10),
  _p('1102300000', 'Davao del Norte', _r11),
  _p('1102400000', 'Davao del Sur', _r11),
  _p('1102500000', 'Davao Oriental', _r11),
  _p('1108200000', 'Davao de Oro', _r11),
  _p('1108600000', 'Davao Occidental', _r11),
  _p('1204700000', 'Cotabato', _r12),
  _p('1206300000', 'South Cotabato', _r12),
  _p('1206500000', 'Sultan Kudarat', _r12),
  _p('1208000000', 'Sarangani', _r12),
  _p('1400100000', 'Abra', _car),
  _p('1401100000', 'Benguet', _car),
  _p('1402700000', 'Ifugao', _car),
  _p('1403200000', 'Kalinga', _car),
  _p('1404400000', 'Mountain Province', _car),
  _p('1408100000', 'Apayao', _car),
  _p('1600200000', 'Agusan del Norte', _r13),
  _p('1600300000', 'Agusan del Sur', _r13),
  _p('1606700000', 'Surigao del Norte', _r13),
  _p('1606800000', 'Surigao del Sur', _r13),
  _p('1608500000', 'Dinagat Islands', _r13),
  _p('1900700000', 'Basilan', _barmm),
  _p('1903600000', 'Lanao del Sur', _barmm),
  _p('1906600000', 'Sulu', _barmm),
  _p('1907000000', 'Tawi-Tawi', _barmm),
  _p('1908700000', 'Maguindanao del Norte', _barmm),
  _p('1908800000', 'Maguindanao del Sur', _barmm),
]);
