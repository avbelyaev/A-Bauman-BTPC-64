#include <iostream>
#include <vector>
#include <fstream>
#include <cstring>
#include <stdint.h>
#include <malloc.h>

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
    Elf64_Half	e_ehsize;		/* ELF header size in OutputCodeDataSize */
    Elf64_Half	e_phentsize;		/* Program header table entry size */
    Elf64_Half	e_phnum;		/* Program header table entry count */
    Elf64_Half	e_shentsize;		/* Section header table entry size */
    Elf64_Half	e_shnum;		/* Section header table entry count */
    Elf64_Half	e_shstrndx;		/* Section header string table index */
} Elf64_Ehdr;

typedef struct {
    Elf64_Word	p_type;     //4 OutputCodeDataSize
    Elf64_Word	p_flags;    //4 OutputCodeDataSize. other fields - 8b long
    Elf64_Off	p_offset;
    Elf64_Addr	p_vaddr;
    Elf64_Addr	p_paddr;
    Elf64_Xword	p_filesz;
    Elf64_Xword	p_memsz;
    Elf64_Xword	p_align;
} Elf64_Phdr;

typedef struct {
    Elf64_Word	sh_name;		/* Section name (string tbl index) */
    Elf64_Word	sh_type;		/* Section type */
    Elf64_Xword	sh_flags;		/* Section flags */
    Elf64_Addr	sh_addr;		/* Section virtual addr at execution */
    Elf64_Off	sh_offset;		/* Section file offset */
    Elf64_Xword	sh_size;		/* Section size in OutputCodeDataSize */
    Elf64_Word	sh_link;		/* Link to another section */
    Elf64_Word	sh_info;		/* Additional section information */
    Elf64_Xword	sh_addralign;		/* Section alignment */
    Elf64_Xword	sh_entsize;		/* Entry size if section holds table */
} Elf64_Shdr;

#define PASCAL_STR_LEN_MAX 255

string NOP = "$90";

ofstream myfile;

int OutputCodeDataSize;
int startStubSize;
int endStubSize;

//shstrtab offset
Elf64_Off endingOffset;

int EndingStubSize;
Elf64_Off TextSectionOffs;
Elf64_Xword TextSectionSize;
Elf64_Off ShstrtabSectionOffs;
Elf64_Xword ShstrtabSectionSize;

Elf64_Off ElfHdrShoff_val_origin;
Elf64_Xword TextPhdrFilesz_val_origin;
Elf64_Xword TextSectionHdrSize_val_origin;
Elf64_Off ShstrtabSectionHdrOffs_val_origin;

vector<int> fileEntrails;
vector<int> endingEntrails;

Elf64_Off SymtabSectionOffs;

Elf64_Off StrtabSectionOffs;

Elf64_Ehdr elfHdr;
Elf64_Phdr dataHdr;
Elf64_Phdr textHdr;
Elf64_Shdr sectHdr;

void findSectionHeaders(FILE *f) {

    rewind(f);
    fread(&elfHdr, 1, sizeof(Elf64_Ehdr), f);
    fread(&dataHdr, 1, sizeof(Elf64_Phdr), f);
    fread(&textHdr, 1, sizeof(Elf64_Phdr), f);

    //cout << "ElfHDRsize: " << hex << sizeof(Elf64_Ehdr) << "; PHDRsize: " << hex << sizeof(Elf64_Phdr) << endl;

    cout << "DataPhdrOffs:=$" << hex << dataHdr.p_offset << endl <<
            "DataPhdrSize:=$" << hex << dataHdr.p_filesz << endl;

    cout << "TextPhdrOffs:=$" << hex << textHdr.p_offset << endl <<
            "TextPhdrSize:=$" << hex << textHdr.p_filesz << endl;

    TextPhdrFilesz_val_origin = textHdr.p_filesz;

    fseek(f, elfHdr.e_shoff + elfHdr.e_shstrndx * sizeof(sectHdr), SEEK_SET);
    fread(&sectHdr, 1, sizeof(sectHdr), f);

    ElfHdrShoff_val_origin = elfHdr.e_shoff;

    cout << "sectHdrSize: " << hex << sizeof(Elf64_Shdr) << endl;
    cout << "e_shoff: " << hex << elfHdr.e_shoff << endl;

    cout << "textPhdrOffs_offs: " << hex << offsetof(Elf64_Phdr, p_filesz) << endl;
    cout << "PHDR sizeof: " << hex << sizeof(Elf64_Phdr) << endl;

    auto textPhdrOffsOffs = sizeof(Elf64_Ehdr) + sizeof(Elf64_Phdr) + offsetof(Elf64_Phdr, p_filesz);
    //cout << "textphdr offs offs auto: " << hex << textPhdrOffsOffs << endl;

    auto sectHdrOffsOffs = elfHdr.e_shoff + 3 * sizeof(Elf64_Shdr) + offsetof(Elf64_Shdr, sh_offset);
    //cout << "sectHdrOffs_offs: " << hex << sectHdrOffsOffs << endl;

    auto memszOffs = offsetof(Elf64_Phdr, p_memsz);
    cout << "memszOffs: " << hex << memszOffs << endl;


    char* SectNames = (char*)malloc(sectHdr.sh_size);
    uint32_t idx;
    Elf64_Off sectionSize;
    Elf64_Off sectionOffset;

    fseek(f, sectHdr.sh_offset, SEEK_SET);
    fread(SectNames, 1, sectHdr.sh_size, f);

    cout << "# / name / offset(hex) / size(hex) / sh_name(hex)" << endl;

    for (idx = 0; idx < elfHdr.e_shnum; idx++) {

        const char* sectionName = "";

        fseek(f, elfHdr.e_shoff + idx * sizeof(sectHdr), SEEK_SET);
        fread(&sectHdr, 1, sizeof(sectHdr), f);

        if (sectHdr.sh_name)
            sectionName = SectNames + sectHdr.sh_name;
        sectionOffset = sectHdr.sh_offset;
        sectionSize = sectHdr.sh_size;
        auto section_sh_name = sectHdr.sh_name;

        cout << idx << " " <<
                sectionName << " " <<
                hex << sectionOffset << " " <<
                hex << sectionSize << " " <<
                hex << section_sh_name << endl;

        if (0 == strcmp(".text", sectionName)) {
            cout << "   TextSectionOffs:=$" << hex << sectionOffset << ";" << endl;
            cout << "   TextSectionSize:=$" << hex << sectionSize << ";" << endl;

            TextSectionOffs = sectionOffset;
            TextSectionSize = sectionSize;
        }

        if (0 == strcmp(".shstrtab", sectionName)) {
            cout << "   ShstrtabSectionOffs:=$" << hex << sectionOffset << ";" << endl;
            cout << "   ShstrtabSectionSize:=$" << hex << sectionSize << ";" << endl;

            endingOffset = sectionOffset;
            cout << "   endingOffset: " << hex << endingOffset << endl;

            ShstrtabSectionOffs = sectionOffset;
            ShstrtabSectionSize = sectionSize;

            ShstrtabSectionHdrOffs_val_origin = sectionOffset;
        }

        if (0 == strcmp(".symtab", sectionName)) {

            SymtabSectionOffs = sectionOffset;
        }
        if (0 == strcmp(".strtab", sectionName)) {

            StrtabSectionOffs = sectionOffset;
        }
    }
}

//fix code size and offs in program hdr and section
//fix shstrtab offset

int* copyEnding(FILE *f, Elf64_Off copyFrom) {

    rewind(f);
    fseek(f, copyFrom, SEEK_SET);

    while (!feof(f)) {

        endingEntrails.push_back(fgetc(f));
    }

    int size = (int)endingEntrails.size();
    EndingStubSize = size;


    int i = 0;
    string one("-1");
    string s = "  OutputCodeString(";
    int bytesInString = 0;
    vector<string> stringList;

    endStubSize = 0;
    while (i < size - 1) {

        if (PASCAL_STR_LEN_MAX == bytesInString) {
            s += ");";
            stringList.push_back(s);

            bytesInString = 0;
            s = "  OutputCodeString(";
        }

        int singleByte = endingEntrails[i];
        //if (0 == one.compare(to_string(singleByte))) cout << singleByte << endl;

        s += "#" + to_string(singleByte);

        bytesInString++;
        i++;
        endStubSize++;
    }

    while (bytesInString < PASCAL_STR_LEN_MAX) {

        s += "#0";// + NOP;
        bytesInString++;
        endStubSize++;
    }
    s += ");";

    stringList.push_back(s);
    //stringList.push_back("  EndingStubSize:=" + to_string(size) + ";");
    stringList.push_back("end;\n");

    //stringList.push_back("  e_shstrndxOffset:=" + to_string(0x3C) + ";");

    myfile << "\n{new}\nprocedure EmitEndingStub;\nbegin\n";
    for (i = 0; i < stringList.size()/*OutputCodeDataSize / PASCAL_STR_LEN_MAX*/; i++) {
        myfile << stringList[i] << endl;
    }


    return NULL;
}

void printConst() {

    myfile << "{new}\nconst EndingStubSize=$" << dec << EndingStubSize << ";\n";

    myfile << "\tStartStubSize=$" << hex << startStubSize << ";\n";
    myfile << "\tEndStubSize=$" << hex << endStubSize << ";\n";

    //myfile << "\tElfHdrShoff_offs=$28;\n";
    //TODO wtf tis value 4d4, not 4f0/530
    myfile << "\tElfHdrShoff_val0=$" << hex << ElfHdrShoff_val_origin << ";\n";


    //myfile << "\tTextPhdrFilesz_offs=$" << hex << (sizeof(Elf64_Ehdr) + sizeof(Elf64_Phdr) + 0x4) << ";\n";
    myfile << "\tTextPhdrFilesz_val0=$" << hex << TextPhdrFilesz_val_origin << ";\n";


    //myfile << "\tTxtSectHdrSize_offs=$" << hex << (ElfHdrShoff_val_origin + 2*sizeof(Elf64_Shdr) + 0x20) << ";\n";
    myfile << "\tTxtSectHdrSize_val0=$" << hex << TextSectionSize << ";\n";


    //myfile << "\tShSectHdrOffs_offs=$" << hex << (ElfHdrShoff_val_origin + 3*sizeof(Elf64_Shdr) + 0x18) << ";\n";
    myfile << "\tShSectHdrOffs_val0=$" << hex << ShstrtabSectionHdrOffs_val_origin << ";\n";

    myfile << "\tSymSHdrOffs_val0=$" << hex << SymtabSectionOffs << ";\n";
    myfile << "\tStrSHdrOffs_val0=$" << hex << StrtabSectionOffs << ";\n";


    myfile << "\tOffsElfHdrShoff=$" << hex << offsetof(Elf64_Ehdr, e_shoff) << ";\n";
    myfile << "\tOffsTextPHdrFilesz=$" << hex <<
         sizeof(Elf64_Ehdr) + sizeof(Elf64_Phdr) + offsetof(Elf64_Phdr, p_filesz) << ";\n";
    myfile << "\tOffsTextSectSize=$" << hex <<
         elfHdr.e_shoff + 2 * sizeof(Elf64_Shdr) + offsetof(Elf64_Shdr, sh_size) << ";\n";

    myfile << "\tOffsShstrSectOffs=$" << hex <<
         elfHdr.e_shoff + 3 * sizeof(Elf64_Shdr) + offsetof(Elf64_Shdr, sh_offset) << ";\n";
    myfile << "\tOffsSymtabSectOffs=$" << hex <<
         elfHdr.e_shoff + 4 * sizeof(Elf64_Shdr) + offsetof(Elf64_Shdr, sh_offset) << ";\n";
    myfile << "\tOffsStrtabSectOffs=$" << hex <<
         elfHdr.e_shoff + 5 * sizeof(Elf64_Shdr) + offsetof(Elf64_Shdr, sh_offset) << ";\n";

    /*cout << "\tTextSectionOffs=$" << hex << TextSectionOffs << ";\n";
    cout << "\tTextSectionSize=$" << hex << TextSectionSize << ";\n";
    cout << "\tShstrtabSectionOffs=$" << hex << ShstrtabSectionOffs << ";\n";
    cout << "\tShstrtabSectionSize=$" << hex << ShstrtabSectionSize << ";\n";*/
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

    myfile.open ("C:\\Users\\anthony\\Documents\\Dropbox\\bero\\rtl64topas\\stub.txt");

    FILE *f = fopen(
            //"/home/anthony/Dropbox/bero/beronew",
            //"/home/anthony/Dropbox/bero/x32/bero32",
            "C:\\Users\\anthony\\Documents\\Dropbox\\berowin\\rtl64",
            //"C:\\Users\\anthony\\Documents\\Dropbox\\berowin\\print",
            "rwb");

    if (!f) {
        cout << "couldnt open file" << endl;
        return -1;
    }

    if (isExecutable(f)) {
        rewind(f);

        cout << "\nLooking up for section headers:" << endl;
        findSectionHeaders(f);


        //scan all
        rewind(f);
        while (feof(f)) {
            fileEntrails.push_back(fgetc(f));
        }
        cout << "OverallBytes:=" << fileEntrails.size() << endl;



        rewind(f);
        vector<string> stringList;
        stringList.clear();

        stringList.push_back("{ab}\nprocedure EmitStubCode;\nbegin");
        stringList.push_back("  OutputCodeDataSize:=0;");

        string s = "  OutputCodeString(";
        int singleByte;

        int bytesInString = 0;
        OutputCodeDataSize = 0;

        while (OutputCodeDataSize < (int)endingOffset) {

            if (PASCAL_STR_LEN_MAX == bytesInString) {
                s += ");";
                stringList.push_back(s);

                bytesInString = 0;
                s = "  OutputCodeString(";
            }

            singleByte = fgetc(f);
            s += "#" + to_string(singleByte);

            bytesInString++;
            OutputCodeDataSize++;
            startStubSize++;
        }

        while (bytesInString < PASCAL_STR_LEN_MAX) {

            s += "#" + NOP;
            bytesInString++;
            startStubSize++;
        }
        s += ");";

        stringList.push_back(s);
        stringList.push_back("  OutputCodeDataSize:=" + to_string(OutputCodeDataSize) + ";");
        stringList.push_back("end;");

        for (int i = 0; i < stringList.size()/*OutputCodeDataSize / PASCAL_STR_LEN_MAX + 1 + 2*/; i++) {

            myfile << stringList[i] << endl;
        }


        //EmitEndingCode

        int *ending = copyEnding(f, endingOffset);


        printConst();

    } else {
        cout << "file is not of ELF format" << endl;
    }

    myfile.close();
    return 0;
}
