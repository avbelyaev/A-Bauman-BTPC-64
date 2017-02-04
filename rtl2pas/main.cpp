#include <iostream>
#include <vector>
#include <fstream>

using namespace std;

/* Type for a 16-bit quantity.  */
typedef uint16_t Elf32_Half;
typedef uint16_t Elf64_Half;

/* Types for signed and unsigned 32-bit quantities.  */
typedef uint32_t Elf32_Word;
typedef	int32_t  Elf32_Sword;
typedef uint32_t Elf64_Word;
typedef	int32_t  Elf64_Sword;

/* Types for signed and unsigned 64-bit quantities.  */
typedef uint64_t Elf32_Xword;
typedef	int64_t  Elf32_Sxword;
typedef uint64_t Elf64_Xword;
typedef	int64_t  Elf64_Sxword;

/* Type of addresses.  */
typedef uint32_t Elf32_Addr;
typedef uint64_t Elf64_Addr;

/* Type of file offsets.  */
typedef uint32_t Elf32_Off;
typedef uint64_t Elf64_Off;

/* Type for section indices, which are 16-bit quantities.  */
typedef uint16_t Elf32_Section;
typedef uint16_t Elf64_Section;

/* Type for version symbol information.  */
typedef Elf32_Half Elf32_Versym;
typedef Elf64_Half Elf64_Versym;

#define EI_NIDENT (16)

typedef struct {
    unsigned char	e_ident[EI_NIDENT];	/* Magic number and other info */
    Elf64_Half	e_type;			/* Object file type */
    Elf64_Half	e_machine;		/* Architecture */
    Elf64_Word	e_version;		/* Object file version */
    Elf64_Addr	e_entry;		/* Entry point virtual address */
    Elf64_Off	e_phoff;		/* Program header table file offset */
    Elf64_Off	e_shoff;		/* Section header table file offset */
    Elf64_Word	e_flags;		/* Processor-specific flags */
    Elf64_Half	e_ehsize;		/* ELF header size in bytes */
    Elf64_Half	e_phentsize;		/* Program header table entry size */
    Elf64_Half	e_phnum;		/* Program header table entry count */
    Elf64_Half	e_shentsize;		/* Section header table entry size */
    Elf64_Half	e_shnum;		/* Section header table entry count */
    Elf64_Half	e_shstrndx;		/* Section header string table index */
} Elf64_Ehdr;

typedef struct {
    Elf64_Word	sh_name;		/* Section name (string tbl index) */
    Elf64_Word	sh_type;		/* Section type */
    Elf64_Xword	sh_flags;		/* Section flags */
    Elf64_Addr	sh_addr;		/* Section virtual addr at execution */
    Elf64_Off	sh_offset;		/* Section file offset */
    Elf64_Xword	sh_size;		/* Section size in bytes */
    Elf64_Word	sh_link;		/* Link to another section */
    Elf64_Word	sh_info;		/* Additional section information */
    Elf64_Xword	sh_addralign;		/* Section alignment */
    Elf64_Xword	sh_entsize;		/* Entry size if section holds table */
} Elf64_Shdr;

#define PASCAL_STR_LEN_MAX 255

string NOP = "$90";

void findSectionHeaders(FILE *f) {

    Elf64_Ehdr elfHdr;
    Elf64_Shdr sectHdr;

    rewind(f);
    fread(&elfHdr, 1, sizeof(Elf64_Ehdr), f);

    fseek(f, elfHdr.e_shoff + elfHdr.e_shstrndx * sizeof(sectHdr), SEEK_SET);
    fread(&sectHdr, 1, sizeof(sectHdr), f);


    char* SectNames = (char*)malloc(sectHdr.sh_size);
    uint32_t idx;
    Elf64_Off sectionSize;
    Elf64_Off sectionOffset;

    fseek(f, sectHdr.sh_offset, SEEK_SET);
    fread(SectNames, 1, sectHdr.sh_size, f);

    cout << "# / name / offset(hex) / size(hex)" << endl;

    for (idx = 0; idx < elfHdr.e_shnum; idx++) {

        const char* sectionName = "";

        fseek(f, elfHdr.e_shoff + idx * sizeof(sectHdr), SEEK_SET);
        fread(&sectHdr, 1, sizeof(sectHdr), f);

        if (sectHdr.sh_name)
            sectionName = SectNames + sectHdr.sh_name;
        sectionOffset = sectHdr.sh_offset;
        sectionSize = sectHdr.sh_size;

        cout << idx << " " <<
                sectionName << " " <<
                hex << sectionOffset << " " <<
                hex << sectionSize << endl;
    }
}

bool isExecutable(FILE *f) {

    if ('M' == fgetc(f) && 'Z' == fgetc(f))
        return true;

    rewind(f);
    fgetc(f);
    return  'E' == fgetc(f) &&
            'L' == fgetc(f) &&
            'F' == fgetc(f);
}

int main() {

    FILE *f = fopen(
            "/home/anthony/Dropbox/bero/beronew",
            //"/home/anthony/Dropbox/bero/x32/bero32",
            //"/home/anthony/Dropbox/bero/btpc.exe",
            "rb");

    if (isExecutable(f)) {
        rewind(f);

        vector<string> stringList;
        stringList.clear();

        stringList.push_back("  OutputCodeDataSize:=0;");

        string s = "  OutputCodeString(";
        int singleByte;

        int bytesInString = 0;
        int bytes = 0;
        while (!feof(f)) {

            if (PASCAL_STR_LEN_MAX == bytesInString) {
                s += ");";
                stringList.push_back(s);

                bytesInString = 0;
                s = "  OutputCodeString(";
            }

            singleByte = fgetc(f);
            s += "#" + to_string(singleByte);

            bytesInString++;
            bytes++;
        }

        while (bytesInString < PASCAL_STR_LEN_MAX) {

            s += "#" + NOP;
            bytesInString++;
        }
        s += ");";

        stringList.push_back(s);
        stringList.push_back("  OutputCodeDataSize:=" + to_string(bytes) + ";");


        for (int i = 0; i < bytes / PASCAL_STR_LEN_MAX + 1 + 2; i++) {

            cout << stringList[i] << endl;
        }



        cout << "Looking up for section headers:" << endl;

        findSectionHeaders(f);

    } else {
        cout << "file is not of ELF format" << endl;
    }

    return 0;
}
