file	bmmod - bitmaps
include	rid:rider
include	rid:medef
include	rid:bmdef

code	bm_alc - allocate a bit map

	RND(x,y) := (((x)+(y-1))&~((y-1)))

  func	bm_alc
	bmp : * bmTbmp
	typ : int
	x   : int
	y   : int
	()  : * bmTbmp
  is	tot : int = bm_tot (typ, x, y)	; total bytes
	bmp = me_acc (#bmTbmp) if !bmp	; get the space
	if bmp->Vtot ne tot		; need a new one
	   bmp->Vtot = 0		;
	   mg_dlc (bmp->Pdat)		; dump what we have
	   mg_alg (0,tot,meALC_)	; allocate another
	   bmp->Pdat = that		;
	.. pass fail			;
	bmp->Vwid = x			;
	bmp->Vhgt = y			;
	bmp->Vtot = tot			;
	bmp->Vtyp = typ			;
	reply bmp			;
  end

code	bm_dlc - deallocate bitmap

  proc	bm_dlc
	bmp : * bmTbmp
  is	mg_dlc (bmp->Pdat)
	me_dlc (bmp)
  end

code	bm_cre - create a bitmap buffer from raw data

  func	bm_cre
	dat : * BYTE
	wid : int
	hgt : int
	()  : * bmTbmp
  is	bmp : * bmTbmp
	bmp = bm_alc (<>, bmPAL, wid, hgt)
	pass fail
	me_mov (dat, bmp->Pdat, wid*hgt)
	reply bmp
  end

code	bm_tot - calculate total bytes

  func	bm_tot
	typ : int
	x   : int
	y   : int
	()  : int
  is	tot : int = 0
	case typ			;
	of bmMON tot = (RND(x,32)/8) * y; monochrome
	of bmPAL tot = RND(x, 4) * y	; palette
	of bmRGB tot = x * 4 * y	; RGB
	end case			;
	reply tot
  end
code	bm_fil - fill bitmap area

  func	bm_fil
	bmp : * bmTbmp
	x   : int
	y   : int
	wid : int
	hgt : int
	hue : int
  is	hor : int			; x move count
	ver : int			; y move count
	maj : int			; major count
	min : int			; minor count
	nxt : * BYTE			; next scan
	lng : * LONG			; long data
	byt : * BYTE			; byte data
	cnt : int			;
	skp : int			; skip count
	msk : int = hue | (hue<<8) 	;
	msk |= (msk<<16)		;
					;
	byt = bm_adr (bmp, x, y, &hor, &ver) ; get first
	fine if !hor || !ver		; nothing to copy
	hor = wid if wid lt hor		; get the smaller of them
	ver = hgt if hgt lt ver		;
	maj = hor / 4			; major loop
	min = hor - (maj * 4)		; minor loop
	skp = bmp->Vwid - wid		; skip count
	while ver--			;
	   lng = <*LONG>byt, cnt = maj	;
	   *lng++ = msk while cnt--	;
	   byt = <*BYTE>lng, cnt = min	;
	   *byt++ = msk while cnt--	;
	   ++hgt			;
	   byt += skp			;
	end
  end

code	bm_adr - compute bitmap address

  func	bm_adr
	bmp : * bmTbmp
	col : int
	row : int
	hor : * int		; remaining columns
	ver : * int		; remaining rows
	()  : * void		; <> if out of range
  is	dat : * BYTE = bmp->Pdat
	wid : int = bmp->Vwid
	hgt : int = bmp->Vhgt
	fail if col ge wid
	fail if row ge hgt
	dat += (row * wid) + col
	*hor = wid - col if hor	; hor remainder
	*ver = hgt - row if ver	; ver remainder
	reply dat
  end
end file

code	bm_loa - load bitmap

HANDLE OpenDIB(LPSTR szFile)
{
    unsigned        fh;
    BITMAPINFOHEADER    bi;
    LPBITMAPINFOHEADER  lpbi;
    DWORD       dwLen = 0;
    DWORD       dwBits;
    HANDLE      hdib;
    HANDLE     h;
    OFSTRUCT   of;

    /* Open the file and read the DIB information */
    fh = OpenFile(szFile, &of, OF_READ);
    if (fh == -1)
        return NULL;

    hdib = ReadDibBitmapInfo(fh);
    if (!hdib)
        return NULL;
    DibInfo(hdib, &bi);

    /* Calculate the memory needed to hold the DIB */
    dwBits = bi.biSizeImage;
    dwLen = bi.biSize + (DWORD) PaletteSize(&bi) + dwBits;

    /* Try to increase the size of the bitmap info. buffer to hold the DIB */
    h = GlobalReAlloc(hdib, dwLen, GHND);
    if (!h) {
        GlobalFree(hdib);
        hdib = NULL;
        }
    else
        hdib = h;

    /* Read in the bits */
    if (hdib) {
        lpbi = (BITMAPINFOHEADER FAR *) GlobalLock(hdib);
        local_read(fh, (LPSTR) lpbi + (WORD) lpbi->biSize + PaletteSize(lpbi), dwBits);
        GlobalUnlock(hdib);
        }
    _lclose(fh);

    return hdib;
}

/****************************************************************************
 *                                      *
 *  FUNCTION   : WriteDIB(LPSTR szFile,HANDLE hdib)             *
 *                                      *
 *  PURPOSE    : Write a global handle in CF_DIB format to a file.      *
 *                                      *
 *  RETURNS    : TRUE  - if successful.                     *
 *       FALSE - otherwise                      *
 *                                      *
 ****************************************************************************/

BOOL WriteDIB(LPSTR szFile, HANDLE hdib)
{
    BITMAPFILEHEADER    hdr;
    LPBITMAPINFOHEADER  lpbi;
    int         fh;
    OFSTRUCT        of;

    if (!hdib)
        return FALSE;

    fh = OpenFile(szFile, &of, OF_CREATE | OF_READWRITE);
    if (fh == -1)
        return FALSE;

    lpbi = (BITMAPINFOHEADER FAR *) GlobalLock(hdib);

    /* Fill in the fields of the file header */
    hdr.bfType = BFT_BITMAP;
    hdr.bfSize = GlobalSize(hdib) + ((UINT)SIZEOF_BITMAPFILEHEADER_PACKED);
    hdr.bfReserved1 = 0;
    hdr.bfReserved2 = 0;
    hdr.bfOffBits = (DWORD) ((UINT)SIZEOF_BITMAPFILEHEADER_PACKED) + lpbi->biSize +
         PaletteSize(lpbi);

    /* Write the file header */
#ifdef __NT__
	WriteMapFileHeaderandConvertFromDwordAlignToPacked(fh, &hdr);
#else
    _lwrite(fh, (LPSTR) &hdr, ((UINT)SIZEOF_BITMAPFILEHEADER_PACKED));
#endif

    /* Write the DIB header and the bits */
    local_write(fh, (LPSTR) lpbi, GlobalSize(hdib));

    GlobalUnlock(hdib);
    _lclose(fh);
    return TRUE;
}
	bm_hdr : (*FILE) *BITMAPINFOHEADER own
code	bm_hdr - read (any) bitmap header

	HDR0	:= 2+4+4+4		; packed header size
	BFT_ICON   := 0x4349		; IC
	BFT_BITMAP := 0x4d42		; BM
	BFT_CURSOR := 0x5450		; PT

  func	bm_hdr
	fil : * FILE
	()  : * BITMAPINFOHEADER
  is	hdr : * BITMAPINFOHEADER
	cor : * BITMAPCOREHEADER
	inf : BITMAPINFOHEADER
	fhd : BITMAPFILEHEADER
	rgb : * RGBQUAD
	wid : LONG
	hgt : LONG
	pln : WORD
	bct : WORD
	pos : long			; base position in file
	siz : size			; size of header
	col : WORD			; number of colours
  is	fail if !fil			; file open failed
	bm_rph (fil, fhd)		; read the file header
	pass fail			;
	pos = fi_pos (fil)		; save current position
	if fhd.bfType ne BFT_BITMAP	; not a bitmap 
	.. fhd.bfOffBits = 0L		; bit offset

	fi_rea (fil, &inf, #inf)	; read the info header
	pass fail			;
	col = DibNumColors (&inf)	; get number of colours

	case (siz = <int>inf.biSize)	; check what we have
	of #BITMAPINFOHEADER		;
	   wid = inf.cWidth		;
	   hgt = inf.cHeight		;
	   pln = inf.cPlanes		;
	   bct = inf.cBitCount		;

	of #BITMAPCOREHEADER		; old style
	   cor = <*BITMAPCOREHEADER>&inf;
	   wid = <LONG>cor->bcWidth	;
	   hgt = <LONG>cor->bcHeight	;
	   pln = cor->bcPlanes		;
	   bct = cor->bcBitCount	;

	   inf.biSize = #BITMAPINFOHEADER;
	   inf.biWidth = wid
	   inf.biHeight = hgt
	   inf.biPlanes = pln
	   inf.biBitCount = bct

	   inf.biCompression = BI_RGB
;	   inf.biSizeImage = 0
;	   inf.biXPelsPerMeter = 0
;	   inf.biYPelsPerMeter = 0
	   inf.biClrUsed = col
	   inf.biClrImportant = col

	   fi_see (fil, pos+HDR0-#BITMAPCOREHEADER)
	of other
	   fail
	end case

	bm_inf (hdr)
	hdr = mg_alc (inf.biSize + #RGBQUAD * col)
	pass fail


	buf : * char
	src : * RGBTRIPLE
	dst : * RGBQUAD
	cnt : int
	val : RGBQUAD

	rgb = <*RGBQUAD>(<*char>hdr + inf.biSize)
	if col				; got colours
	   if siz eq #BITMAPCOREHEADER	; got old colours
	      fi_rea (fil, buf, col * #RGBTRIPLE)
	      fail mg_dlc (hdr) if fail
	      src = <*RGBTRIPLE>(buf + ((col-1) * 3))
	      dst = <*RGBQUAD>(buf + ((col-1) * 4))
	      cnt = col
	      while cnt--
		 val.rgbRed = src->rgbtRed
		 val.rgbBlue = src->rgbtBlue
		 val.rgbGreen = src->rgbtGreen
	         val.rgbReserved = 0
		 *dst = val
		 --src, --dst
	      end
	   else
	      fi_rea (fil, rgb, col * #RGBQUAD)
	.. .. fail mg_dlc (hdr) if fail

	if fhd.bfOffBits 
	   fi_pos (fil, fhd.bfOffBits)
	.. fail mg_dlc (hdr) if fail
	reply hdr
  end


HANDLE ReadDibBitmapInfo(int fh)
{
    DWORD     off;			; off
    int   size;
    int   i;
    WORD      nNumColors;

    HANDLE    hbi = NULL;
    LPBITMAPINFOHEADER lpbi;		; hdr

    RGBQUAD FAR *pRgb;			;
    BITMAPINFOHEADER   bi;		; inf
    BITMAPCOREHEADER   bc;		; cor
    BITMAPFILEHEADER   bf;		; fhd
    DWORD          dwWidth = 0;		; wid
    DWORD          dwHeight = 0;	; hgt
    WORD           wPlanes, wBitCount	; pln


    /* Do we have a RC HEADER? */
    if (! ISDIB (bf.bfType)) {
        bf.bfOffBits = 0L;
        _llseek(fh, off, SEEK_SET);
        }
    if (sizeof (bi) != _lread(fh, (LPSTR) &bi, sizeof (bi)))
        return FALSE;

    nNumColors = DibNumColors(&bi);

    /* Check the nature (BITMAPINFO or BITMAPCORE) of the info. block
     * and extract the field information accordingly. If a BITMAPCOREHEADER,
     * transfer it's field information to a BITMAPINFOHEADER-style block
     */


    switch (size = (int) bi.biSize) {
  case sizeof(BITMAPINFOHEADER):
        break;

  case sizeof(BITMAPCOREHEADER):

        bc = *(BITMAPCOREHEADER *) &bi;

        dwWidth = (DWORD) bc.bcWidth;
        dwHeight = (DWORD) bc.bcHeight;
        wPlanes = bc.bcPlanes;
        wBitCount = bc.bcBitCount;

        bi.biSize = sizeof(BITMAPINFOHEADER);
        bi.biWidth = dwWidth;
        bi.biHeight = dwHeight;
        bi.biPlanes = wPlanes;
        bi.biBitCount = wBitCount;

        bi.biCompression = BI_RGB;
        bi.biSizeImage = 0;
        bi.biXPelsPerMeter = 0;
        bi.biYPelsPerMeter = 0;
        bi.biClrUsed = nNumColors;
        bi.biClrImportant = nNumColors;

        _llseek(fh, (LONG) sizeof(BITMAPCOREHEADER) -
             sizeof(BITMAPINFOHEADER), SEEK_CUR);
        break;

  default:
        /* Not a DIB! */
        return NULL;
        }

    /*  Fill in some default values if they are zero */
    if (bi.biSizeImage == 0) {
        bi.biSizeImage = WIDTHBYTES ((DWORD)bi.biWidth * bi.biBitCount)
              * bi.biHeight;
        }
    if (bi.biClrUsed == 0)
        bi.biClrUsed = DibNumColors(&bi);

    /* Allocate for the BITMAPINFO structure and the color table. */
    hbi = GlobalAlloc(GHND, (LONG) bi.biSize + nNumColors * sizeof(RGBQUAD));
    if (!hbi)
        return NULL;
    lpbi = (BITMAPINFOHEADER FAR *) GlobalLock(hbi);
    *lpbi = bi;


;----------------

    /* Get a pointer to the color table */
    pRgb = (RGBQUAD FAR *) ((LPSTR) lpbi + bi.biSize);
    if (nNumColors) {
        if (size == sizeof(BITMAPCOREHEADER)) {
        /* Convert a old color table (3 byte RGBTRIPLEs) to a new
         * color table (4 byte RGBQUADs)
         */
            _lread(fh, (LPSTR) pRgb, nNumColors * sizeof(RGBTRIPLE));

            for (i = nNumColors - 1;  i >= 0;  i--) {
                RGBQUAD rgb;

                rgb.rgbRed = ((RGBTRIPLE FAR *) pRgb)[i].rgbtRed;
                rgb.rgbBlue = ((RGBTRIPLE FAR *) pRgb)[i].rgbtBlue;
                rgb.rgbGreen = ((RGBTRIPLE FAR *) pRgb)[i].rgbtGreen;
                rgb.rgbReserved = (BYTE) 0;

                pRgb[i] = rgb;
                }
            }
        else
            _lread(fh, (LPSTR) pRgb, nNumColors * sizeof(RGBQUAD));
        }

;------------

    if (bf.bfOffBits != 0L)
        _llseek(fh, off + bf.bfOffBits, SEEK_SET);

    GlobalUnlock(hbi);
    return hbi;
}

code	bm_inf - fill in info stuff

  func	bm_inf
	inf : * BITMAPINFOHEADER
  is	if !inf.biSizeImage
	.. inf.biSizeImage =  ((((wid * bct) + 31) / 32) * 4) * hgt
	if !inf.biClrUsed
	.. inf.biClrUsed = col
	fine
  end

BOOL DibInfo(HANDLE hbi, LPBITMAPINFOHEADER lpbi)
{
    if (hbi) {
        *lpbi = *(LPBITMAPINFOHEADER) GlobalLock(hbi);

    /* fill in the default fields */
        if (lpbi->biSize != sizeof(BITMAPCOREHEADER)) {
            if (lpbi->biSizeImage == 0L)
                lpbi->biSizeImage =
                     WIDTHBYTES(lpbi->biWidth*lpbi->biBitCount) * lpbi->biHeight;

            if (lpbi->biClrUsed == 0L)
                lpbi->biClrUsed = DibNumColors(lpbi);
            }
        GlobalUnlock(hbi);
        return TRUE;
        }
    return FALSE;
}
code	bm_rph - read packed header

;	This code works for both W16 and W32

  func	bm_rph
	fil : * FILE
	hdr : * BITMAPFILEHEADER
  is	fi_rea (fil, <*void> &hdr->bfType, #WORD)
	fi_rea (fil, <*void> &hdr->bfSize, #DWORD*3)
  end

code	bm_wph - write packed header

  func	bm_rph
	fil : * FILE
	hdr : * BITMAPFILEHEADER
  is	fi_wri (fil, <*void> &hdr->bfType, #WORD)
	fi_wri (fil, <*void> &hdr->bfSize, #DWORD*3)
  end
