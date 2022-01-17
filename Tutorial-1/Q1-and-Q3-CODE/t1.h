#pragma once
extern "C" int bias;
// Extern C to make it a C function, we do it because this is implemented in assembly
// _cdecl basically declares a C calling convention
extern "C" int _cdecl poly(int);
extern "C" int _cdecl multiple_k(uint16_t, uint16_t, uint16_t, uint16_t*);
extern "C" int _cdecl factorial(int);