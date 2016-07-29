#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

// Sample code - convert a hexencoded string into a binary array and
// viceversa.  Also include some other interesting uses of arrays,
// strings, enums and callbacks

typedef enum {
  msFalse = 0,
  msTrue  = 1,
} msbool;


typedef enum {
  msERROR,
  msWARN,
  msINFO,
  msDEBUG,
} debug_level;


// Structure to do mappings of an enum to a string.

typedef struct {
  int id;
  const char *name;
} id_to_string;


// A constant value that defines the 'maximum' ID value. Note that
// this is arbitrary right now but it would likely be based on
// whatever is the maximum enum value for a system (max int?)

#define MAX_ID 9999999

id_to_string debug_level_names[] = {
  { msERROR, "ERROR"   },
  { msWARN,  "WARNING" },
  { msINFO,  "INFO"    },
  { msDEBUG, "DEBUG"   },
  { MAX_ID,  NULL      },
};


id_to_string bool_names[] = {
  { msTrue,  "TRUE"  },
  { msFalse, "FALSE" },
  { MAX_ID,  NULL    },
};

// Assumption all id_to_string maps will end with id = MAX_ID

static const char *map_id_to_string(int id, id_to_string *map)
{
  size_t i = 0;

  if (map == NULL) {
    return "invalid map";
  }

  while(map[i].id != MAX_ID) {
    if (map[i].id == id) {
      return (map[i].name == NULL) ? "(NULL)" : map[i].name;
    }
    i++;
  } 

  // If we reach here then the id wasn't found.
  return "unknown";
}

static void msLog(debug_level level, const char *message)
{
  printf("%s - %s\n", map_id_to_string((int)level, debug_level_names), message);
}

// returns msTrue if c is a number
static msbool is_digit(char c)
{
  // I like to use the ternary operator when things are fairly simple:
  return (c >= '0' && c <= '9') ? msTrue : msFalse;
}

// returns msTrue if c is a valid hex digit (0-9 or a-f)
static msbool is_hexchar(char c)
{
  if (is_digit(c)) {
    return msTrue;
  } else {
    char upcase_c = toupper(c);
    return (upcase_c >= 'A' && upcase_c <= 'F') ? msTrue : msFalse;
  }
}


static unsigned char nib_to_bin(char nib)
{
  if (is_hexchar(nib)) {
    if (is_digit(nib)) {
      return (unsigned char)(nib - '0');
    } else {
      return (unsigned char)(toupper(nib) - 'A' + 0xA);
    }
  }
  // error
  return '\0';
}

// Creates an array with the binary interpretation of a hex
// string. Resulting array needs to be freed()

static unsigned char *hex_to_bin(const char *hexstr, size_t *out_len)
{
  size_t i, len;
  unsigned char *allocd = NULL;

  *out_len = 0;

  if (hexstr == NULL) {
    msLog(msWARN, "Null hex strings maps to NULL binary array\n");
    return NULL;
  }

  len = strlen(hexstr);

  if (len % 2 != 0) {
    // invalid hex string
    msLog(msERROR, "Invalid hex string; A valid hex string must be even in lenght\n");
    return NULL;
  }

  allocd = malloc(len/2);

  if (allocd == NULL) {
    msLog(msERROR, "Could not allocate memory for binary array");
    return NULL;
  }

  for (i = 0; i < len/2; i++) {
    const char nib1 = hexstr[i*2];
    const char nib2 = hexstr[i*2+1];
    if (is_hexchar(nib1) == msFalse || is_hexchar(nib2) == msFalse) {
      msLog(msERROR, "Invalid character found in hex string - aborting");
      free(allocd);
      return NULL;
    }
    
    allocd[i] = (nib_to_bin(nib1) << 4) + nib_to_bin(nib2);
    printf("H2B: %0x%0x == %0x\n", nib1, nib2, allocd[i]);
  }
  *out_len = len/2;
  return allocd;
}



static char nib_to_char(unsigned char nib)
{
  return (nib < 0xA) ? ('0' + nib) : ('A' + (nib - 0xA));
}


static char *bin_to_hex(const unsigned char *data, size_t len)
{
  size_t i;
  char *allocd = NULL;

  if (data == NULL || len == 0) {
    msLog(msWARN, "Null bin array maps to NULL hex string\n");
    return NULL;
  }

  allocd = malloc(len*2+1); // Add one for the null at the end

  if (allocd == NULL) {
    msLog(msERROR, "Could not allocate memory for hex string");
    return NULL;
  }

  for (i = 0; i < len; i++) {
    allocd[i*2]   = nib_to_char(data[i] / 0x10);
    allocd[i*2+1] = nib_to_char(data[i] % 0x10);
    printf("B2H: %0x == %c%c\n", data[i], allocd[i*2], allocd[i*2+1]);
  }

  allocd[len*2] = '\0';
  return allocd;
}


int main( int argc, const char* argv[] )
{
  const char *hexstr = "1234567890abcdef";
  size_t len;
  unsigned char *asbin = hex_to_bin(hexstr, &len);

  if (asbin != NULL) {
    char *ashex;
    msLog(msINFO, "Generated binary array");
    ashex = bin_to_hex(asbin, len);

    if (ashex != NULL) {
      msLog(msINFO, "Generated hex string from binary array");

      // Use strcasecmp since 'a' == 'A' in hex
      if (strcasecmp(ashex, hexstr) == 0) {
	msLog(msINFO, "binary array, when converted to hex, matches initial hex string");
      } else {
	msLog(msERROR, "binary array, when converted to hex, does not match initial hex string");
      }
      msLog(msDEBUG, ashex);
      msLog(msDEBUG, hexstr);

      free(ashex);
    }

    free(asbin);
  } else {

    msLog(msERROR, "asbin is NULL");
  }

  return 0;
}
