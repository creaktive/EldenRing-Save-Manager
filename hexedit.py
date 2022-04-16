import binascii, re, hashlib, random, base64



def l_endian(val):
    """Takes bytes and returns little endian int32/64"""
    l_hex = bytearray(val)
    l_hex.reverse()
    str_l = ''.join(format(i, '02x') for i in l_hex)
    return int(str_l, 16)



def recalc_checksum(file):
    with open (file, 'rb') as fh:
        dat = fh.read()
        slot_ls = []
        slot_len = 2621439
        cs_len = 15
        s_ind = 0x00000310
        c_ind = 0x00000300


        # Build nested list containing data and checksum related to each slot
        for i in range(10):
            d = dat[s_ind: s_ind + slot_len +1] # [ dat[0x00000310:0x0028030F +1], dat[ 0x00000300:0x0000030F + 1] ]
            c = dat[c_ind: c_ind + cs_len + 1]
            slot_ls.append([d,c])
            s_ind += 2621456
            c_ind += 2621456



        # Do comparisons and recalculate checksums
        for ind,i in enumerate(slot_ls):
            new_cs = hashlib.md5(i[0]).hexdigest()
            cur_cs = binascii.hexlify(i[1]).decode('utf-8')

            if new_cs != cur_cs:
                slot_ls[ind][1] = binascii.unhexlify(new_cs)



        slot_len = 2621439
        cs_len = 15
        s_ind = 0x00000310
        c_ind = 0x00000300
        # Insert all checksums into data
        for i in slot_ls:
            dat = dat[:s_ind] + i[0] + dat[s_ind + slot_len +1:]
            dat = dat[:c_ind] + i[1] + dat[c_ind + cs_len + 1:]
            s_ind += 2621456
            c_ind += 2621456


        # Manually doing General checksum
        general = dat[0x019003B0:0x019603AF +1]
        new_cs = hashlib.md5(general).hexdigest()
        cur_cs = binascii.hexlify(dat[0x019003A0:0x019003AF + 1]).decode('utf-8')

        writeval = binascii.unhexlify(new_cs)
        dat = dat[:0x019003A0] + writeval + dat[0x019003AF +1:]




        with open(file, 'wb') as fh1:
            fh1.write(dat)



def replacer(file,slot,name):
    with open(file, "rb") as fh:
        dat1 = fh.read()
        id_loc = []
        index = 0

        while index < len(dat1):
            index = dat1.find(slot.rstrip(b'\x00'), index)

            if index == -1:
                break
            id_loc.append(index)
            if len(id_loc) > 300:
                return 'error'
            index += 8

        nw_nm_bytes = name.encode('utf-16')[2:]

        num = 32 - len(nw_nm_bytes)
        for i in range(num):
            nw_nm_bytes = nw_nm_bytes + b'\x00'

        for i in id_loc:
            fh.seek(0)
            a = fh.read(i)
            b = nw_nm_bytes
            fh.seek(i + 32)
            c = fh.read()
            data = a + b + c

            with open(file, 'wb') as f:
                f.write(data)
    recalc_checksum(file)



def change_name(file,nw_nm,dest_slot):

    empty = b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    with open(file, 'rb') as fh:
        dat1 = fh.read()


    name_locations = []
    ind1 = 0x1901d0e
    for i in range(10):
        nm = dat1[ind1: ind1 + 32]
        name_locations.append(nm)
        ind1 += 588

    x = replacer(file, name_locations[dest_slot -1], nw_nm )
    return x



def replace_id(file,newid):
    id_loc = []
    index = 0

    with open(file, "rb") as f:
        dat = f.read()
        f.seek(26215348) # start address of steamID
        steam_id = f.read(8) # Get steamID

        id_loc = []
        index = 0
        while index < len(dat):
            index = dat.find(steam_id, index)
            if index == -1:
                break
            id_loc.append(index)
            index += 8

        for i in id_loc:
            f.seek(0)
            a = f.read(i)
            b =  newid.to_bytes(8, 'little')
            f.seek(i + 8)
            c = f.read()
            data = a + b + c

            with open(file, 'wb') as fh:
                fh.write(data)

    recalc_checksum(file)



def copy_save(src_file,dest_file,src_char,dest_char):
    slot_len = 2621456
    lvls = get_levels(src_file)
    lvl = lvls[src_char -1]

    with open (src_file, 'rb') as fh:
        dat = fh.read()


    if src_char == 1:
        src_slot = dat[0x00000310:0x0028030F +1]
    else:
        src_slot = dat[0x00000310 + (src_char -1) * slot_len:( 0x0028030F + ((src_char -1) * slot_len) ) +1]

    with open(dest_file, "rb") as fh:
        dat1 = fh.read()

    if dest_char == 1:
        slot_s = dat1[:0x00000310]
        slot_e = dat1[0x0028030F +1:]
    else:
        slot_s = dat1[:0x00000310 + ( (dest_char -1) * slot_len )]
        slot_e = dat1[ 0x0028030F + ((dest_char -1) * slot_len )  +1:]


    dat1 = slot_s + src_slot + slot_e


    with open(dest_file, 'wb') as fh:
        fh.write(dat1)

    set_level(dest_file, dest_char, lvl)



def get_id(file):
    with open(file, "rb") as f:
        dat = f.read()
        f.seek(26215348) # start address of steamID
        steam_id = f.read(8) # Get steamID
    return l_endian(steam_id)



def get_names(file):
    with open(file, "rb") as fh:
        dat1 = fh.read()


    name1 = dat1[0x1901d0e:0x1901d0e + 32].decode('utf-16')
    name2 = dat1[0x1901f5a:0x1901f5a + 32].decode('utf-16')
    name3 = dat1[0x19021a6:0x19021a6 + 32].decode('utf-16')
    name4 = dat1[0x19023f2 :0x19023f2  +32].decode('utf-16')
    name5 = dat1[0x190263e :0x190263e  +32].decode('utf-16')
    name6 = dat1[0x190288a :0x190288a  +32].decode('utf-16')
    name7 = dat1[0x1902ad6 :0x1902ad6  +32].decode('utf-16')
    name8 = dat1[0x1902d22 :0x1902d22  +32].decode('utf-16')
    name9 = dat1[0x1902f6e :0x1902f6e  +32].decode('utf-16')
    name10 = dat1[0x19031ba :0x19031ba  +32].decode('utf-16')


    names = [name1,name2,name3,name4,name5,name6,name7,name8,name9,name10]


    for ind,i in enumerate(names):
        if i == '\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00':
            names[ind] = None

    for ind,i in enumerate(names):
        if not i is None:
            names[ind] = i.split('\x00')[0] # name looks like this: 'wete\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'

    return names



def random_str():
    """Generates random 16 character long name"""
    val = range(random.randint(900,900000))
    hashed = hashlib.sha1(str(val).encode())
    random_name = base64.urlsafe_b64encode(hashed.digest()[:12])
    return random_name.decode("utf-8")



def get_slot_ls(file):
    with open(file, 'rb') as fh:
        dat = fh.read()

        slot1 = dat[0x00000310:0x0028030F +1] # SLOT 1
        slot2 = dat[0x00280320:0x050031F + 1]
        slot3 = dat[0x500330:0x78032F +1]
        slot4 = dat[0x780340:0xA0033F +1]
        slot5 = dat[0xA00350:0xC8034F +1]
        slot6 = dat[0xC80360:0xF0035F +1]
        slot7 = dat[0xF00370:0x118036F +1]
        slot8 = dat[0x1180380:0x140037F +1]
        slot9 = dat[0x1400390:0x168038F +1]
        slot10 = dat[0x16803A0:0x190039F +1]
        return [slot1,slot2,slot3,slot4,slot5,slot6,slot7,slot8,slot9,slot10]


def get_slot_slices(file):
    with open(file, 'rb') as fh:
        dat = fh.read()

    slot1_start = dat[:0x00000310]
    slot1_end = dat[0x0028030F +1:]

    slot2_start = dat[:0x00280320]
    slot2_end = dat[0x050031F + 1:]

    slot3_start = dat[:0x500330]
    slot3_end = dat[0x78032F +1:]


    slot4_start = dat[:0x780340]
    slot4_end = dat[0xA0033F +1:]

    slot5_start = dat[:0xA00350]
    slot5_end = dat[0xC8034F +1:]

    slot6_start = dat[:0xC80360]
    slot6_end = dat[0xF0035F +1:]

    slot7_start = dat[:0xF00370]
    slot7_end = dat[0x118036F +1:]

    slot8_start = dat[:0x1180380]
    slot8_end = dat[0x140037F +1:]

    slot9_start = dat[:0x1400390]
    slot9_end = dat[0x168038F +1:]

    slot10_start = dat[:0x16803A0]
    slot10_end = dat[0x190039F +1:]

    return [ [slot1_start,slot1_end], [slot2_start,slot2_end], [slot3_start,slot3_end],[slot4_start,slot4_end],[slot5_start,slot5_end],[slot6_start,slot6_end],[slot7_start,slot7_end],[slot8_start,slot8_end],[slot9_start,slot9_end],[slot10_start,slot10_end] ]



def set_stats(file, char_num, stat_ls):

    locs = get_stats(file,char_num)[1] # list of index values of stats

    index = 0
    for loc in locs: # last val is lvl
        slots = get_slot_ls(file)
        slot_slices = get_slot_slices(file)
        dest_char = slots[char_num -1]

        if index == 8:
        # Last val is lvl index
            lvl_ind = loc

            level = dest_char[lvl_ind:lvl_ind+1]
            new_lv = sum(stat_ls) - 79
            new_lvl_int = new_lv
            new_lv = new_lv.to_bytes(2,'little')
            data = slot_slices[char_num -1][0]  +  dest_char[:lvl_ind]  +  new_lv  +  dest_char[lvl_ind +2:]  +  slot_slices[char_num -1][1]
            with open(file, 'wb') as fh:
                fh.write(data)
            break


        writeval = stat_ls[index].to_bytes(1, 'little')
        #total = dat[:0x00000310] + slot[:47496] + b'c' + slot[47496 +1:] + dat[0x0028030F +1:]
        data = slot_slices[char_num -1][0]  +  dest_char[:loc]  +  writeval  +  dest_char[loc +1:]  +  slot_slices[char_num -1][1]
        with open(file, 'wb') as fh:
            fh.write(data)
        index += 1


    set_level(file, char_num, new_lvl_int )



def get_stats(file, char_slot):
    """"""
    lvls = get_levels(file)
    lv = lvls[char_slot -1]
    slots = get_slot_ls(file)
    with open(file, 'rb') as fh:
        dat = fh.read()

    start_ind = 0
    slot1 = slots[char_slot -1]
    indexes = []
    for ind,b in enumerate(slot1):
        if ind > 60000:
            return None
        try:
            stats = [l_endian(slot1[ind:ind+1]), l_endian(slot1[ind + 4:ind+5]), l_endian(slot1[ind + 8:ind+9]), l_endian(slot1[ind + 12:ind+13]), l_endian(slot1[ind + 16:ind + 17]), l_endian(slot1[ind + 20: ind +21]), l_endian(slot1[ind + 24:ind+25]), l_endian(slot1[ind + 28:ind+29]) ]

            if sum(stats) == lv + 79 and l_endian(slot1[ind + 44: ind + 46 ]) == lv:
                start_ind = ind
                lvl_ind = ind + 44
                break

        except:
            continue

    idx = ind
    for i in range(8):
        indexes.append(idx)
        idx += 4

    indexes.append(lvl_ind) # Add the level location to the end o
    return [stats,indexes] # [[36, 16, 38, 33, 16, 9, 10, 7], 47421]



def set_level(file,char,lvl):
    """Sets levels in static header position by char names for in-game load save menu."""
    locs = [26221872,26222460,26223048,26223636,26224224,26224812,26225400,26225988,26226576,26227164]
    with open(file, 'rb') as fh:
        dat = fh.read()
        a = dat[:locs[char -1]]
        b = lvl.to_bytes(2, 'little')
        c = dat[locs[char -1] + 2:]
        data = a + b + c

    with open(file, 'wb') as f:
        f.write(data)
    recalc_checksum(file)



def get_levels(file):
    with open(file, 'rb') as fh:
        dat = fh.read()

    ind = 0x1901d0e + 34
    lvls = []
    for i in range(10):
        l = dat[ind: ind + 2]

        lvls.append(l_endian(l))
        ind += 588
    return lvls
