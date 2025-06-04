[BITS 16]
[ORG 0x7C00]

jmp short main
nop

; ───── BIOS Parameter Block ─────
bdb_oem_name:              db "IfnOS   "
bdb_bytes_per_sector:      dw 512           
bdb_sectors_per_cluster:   db 1                
bdb_reserved_sectors:      dw 1                
bdb_fat_count:             db 2                
bdb_root_dir_entries:      dw 224              
bdb_total_sectors_short:   dw 2880             
bdb_media_descriptor:      db 0xF0             
bdb_sectors_per_fat:       dw 9                
bdb_sectors_per_track:     dw 18               
bdb_number_of_heads:       dw 2                
bdb_hidden_sectors:        dd 0                
bdb_total_sectors_long:    dd 0                

; ───── Extended BPB (EBPB) ─────
ebr_drive_number:          db 0x00             ; 0x00 for floppy
ebr_reserved:              db 0x00             
ebr_signature:             db 0x29             
ebr_volume_id:             dd 0x12345678       
ebr_volume_label:          db "IFNOS_BOOT "
ebr_file_system_id:        db "FAT12   "       

; ───── Bootloader Main ─────
main:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7E00     ; Set stack pointer 0x7C00 + 512 = 0x7E00
    sti

    ; Print welcome message
    cld
    mov si, msg
    call _print
    
    ; Disk Reset before Read — good practice
    call disk_reset

    ; Attempt to read 1 sector from disk (sector 2)
    call disk_read
    
    jmp $


    
; ───── Read from Disk ─────
disk_read:
    mov cx,2
    
read_try: ; ───── Disk Read Try ─────
    mov ah, 0x02        ; BIOS read sector
    mov al, 1           ; Read 1 sector
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Sector 2 (CHS: sector starts at 1)
    mov dh, 0           ; Head 0
    mov dl, [ebr_drive_number]  ; Drive (0x00 for floppy)
    mov bx, 0x0000
    mov es, 0x0500      ; Store data at ES:BX = 0x0500:0000
    int 0x13            ; BIOS interrupt to read disk
    
    jc read_fail
    jmp disk_success
    
   
read_fail:
   loop read_try
   jmp disk_error 
    
disk_success:
    cld
    mov si, msg_success
    call _print
    jmp _return
    
; ───── Disk Read Error ─────
disk_error:
    cld
    mov si, msg_error
    call _print
    jmp _here
    
; ───── Disk Reset ─────
disk_reset:
   mov ah,0x00
   mov dl,[ebr_drive_number]
   int 0x13
   jmp _return

; ───── Print Routine ─────
_print:
    lodsb
    cmp al, 0
    je _return
    mov ah, 0x0E
    int 0x10
    jmp _print
    
; ───── Return ─────
_return:
    ret
    
; ───── Hang Loop ─────
_here:
    jmp _here

; ───── Messages ─────
msg:          db "IfnOS - an eXperimental OS", 0xA, 0
msg_success:  db "Disk read success!", 0xA, 0
msg_error:    db "Disk read failed!", 0xA, 0

; ───── Boot Signature ─────
times 510 - ($ - $$) db 0
dw 0xAA55
