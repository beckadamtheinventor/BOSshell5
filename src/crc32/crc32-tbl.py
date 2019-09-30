

def hexbyte(h):
	a="0123456789ABCDEF"
	return a[h//0x10]+a[h&0xF]

def Generate_CRC32_Tbl():
	polynomial = 0x04C11DB7;
	crcTable = [0]*256;
	for divident in range(256):
		curByte = (divident<<24)&0xFF000000
		for bit in range(8):
			if curByte & 0x80000000:
				curByte *= 2
				curByte = curByte ^ polynomial
			else:
				curByte *= 2
		crcTable[divident] = curByte&0xFF
	return crcTable

def Compute_CRC32(bytelist):
	crc = 0
	for b in bytelist:
		pos = (crc^(b << 24) >> 24)&0xFF
		crc = (crc << 8) ^ crcTable[pos]
	return crc

if __name__=='__main__':
	data=Generate_CRC32_Tbl()
	with open("tbl.asm","w") as f:
		f.write("crc32_table:\n")
		for y in range(16):
			f.write("\tdb\t")
			for x in range(16):
				f.write("$"+hexbyte(data[y*16+x]))
				if x<15:
					f.write(", ")
			f.write("\n")
	
