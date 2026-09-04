/*
WAYOB by Alyx Shang.
Licensed under the FSL v1.
*/

#include <wayob.h>
#include <stdio.h>
#include <libadd.h>

CFrame add_nums(const CFrame* list, size_t len) { 
      CFrame left = list[0];
      CFrame right = list[1];
      int64_t sum = left.payload.Integer + right.payload.Integer;
     return (CFrame){ 
       .tag = Integer, 
       .payload = { .Integer = sum } 
     };
}
