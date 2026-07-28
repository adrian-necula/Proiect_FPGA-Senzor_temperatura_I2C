# Proiect_FPGA-Senzor_temperatura_I2C
Proiect FPGA pentru citirea temperaturii prin I2C, afisarea pe 7 segmente si transmiterea valorii prin UART.

## I2C și citirea temperaturii
Implementați un master I2C în SystemVerilog, fără IP core-uri Xilinx. Master-ul trebuie să comunice cu senzorul de temperatură de pe placă, să citească periodic valoarea temperaturii și să o convertească în grade Celsius conform specificațiilor din datasheet-ul senzorului.


## Rezolvare

Am inceput proiectul prin documentarea despre protocolul I2C si despre comunicarea dintre un dispozitiv master si unul sau mai multe dispozitive slave.

Am impartit proiectul in urmatoarele module:

- i2c_master - realizeaza operatiile de baza ale protocolului I2C;
- temp_controller - controleaza comenzile necesare citirii senzorului;
- temp_converter - converteste valoarea citita in grade Celsius.

Pentru afisarea temperaturii si a counter-ului voi reutiliza si adapta modulele realizate in primul proiect:

- binary_to_decimal;
- num;
- mux;
- transcodor_7seg;
- decodor_anod.

Temperatura va fi afisata pe cei patru digiti din stanga, iar counter-ul pe cei patru digiti din dreapta.


### Protocolul I2C

I2C este un protocol de comunicatie seriala sincrona care foloseste doua linii:

- SCL - semnalul de clock generat de master;
- SDA - linia bidirectionala folosita pentru transmiterea si receptionarea datelor.

O transmisie I2C contine:

- conditia de START;
- adresa slave-ului si bitul de citire/scriere;
- bitul ACK;
- transmiterea sau receptionarea datelor;
- transmiterea unui ACK sau NACK dupa citire;
- conditia de STOP.

Pentru implementare am ales frecventa standard de 100 kHz. Fiecare bit este impartit in patru faze, iar numarul de cicluri pentru o faza este:

DIVIDER = CLK_FREQ / (4 * I2C_FREQ)

Pentru un clock de 100 MHz si o frecventa I2C de 100 kHz rezulta:

DIVIDER = 250 cicluri

Cele patru faze ale unui bit sunt:

- faza 0 - SCL este 0 si se pregateste valoarea SDA;
- faza 1 - SCL trece la 1;
- faza 2 - valoarea SDA este mentinuta sau citita;
- faza 3 - SCL revine la 0.


## Structura modulului i2c_master

Modulul primeste comanda prin cmd, iar cmd_start porneste executarea acesteia. Byte-ul transmis este primit prin din, iar byte-ul receptionat este disponibil pe dout.

Am stabilit urmatoarele comenzi:

- CMD_START;
- CMD_WRITE;
- CMD_READ_ACK;
- CMD_READ_NACK;
- CMD_STOP.

Modulul este gandit sub forma unui FSM cu starile:

- IDLE - asteapta o comanda;
- START - genereaza conditia de START;
- WRITE - transmite cei 8 biti;
- WRITE_ACK - citeste ACK-ul trimis de slave;
- READ - receptioneaza cei 8 biti;
- READ_ACK - transmite ACK sau NACK;
- STOP - genereaza conditia de STOP.

