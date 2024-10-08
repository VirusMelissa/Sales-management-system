﻿CREATE VIEW ABC
AS
SELECT HOADON.SOHD, SANPHAM.MASP, SL, GIA, SL*GIA AS THANHTIEN
FROM CTHD, HOADON, SANPHAM
WHERE CTHD.SOHD = HOADON.SOHD
AND SANPHAM.MASP = CTHD.MASP


SELECT * FROM ABC



CREATE TRIGGER TR_THEMTRONGVIEWS
ON ABC INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS (SELECT SOHD FROM inserted)
	BEGIN TRAN THEM
	BEGIN
		--ton tai mau tin nao do trong bang inserted nhưng khong co MANV nam trong bang HOADON
		IF(EXISTS(SELECT SOHD FROM inserted WHERE SOHD NOT IN(SELECT SOHD FROM HOADON)))
		BEGIN
			--quay lai
			ROLLBACK TRAN THEM
		END
		--ton tai mau tin nao do trong bang inserted nhưng khong co MADA nam trong bang SANPHA,
		IF(EXISTS(SELECT MASP FROM inserted WHERE MASP NOT IN(SELECT MASP FROM SANPHAM)))
		BEGIN
			--quay lai
			ROLLBACK TRAN THEM
		END
	END

	--nếu bị 1 lỗi thì sẽ ko thêm được
	IF @@ERROR=1
	BEGIN
		ROLLBACK TRAN THEM
	END
	--ngược lại thì sẽ thêm được
	ELSE
	BEGIN
		INSERT INTO CTHD
		SELECT SOHD,MASP,SL FROM inserted
		COMMIT TRAN THEM
		PRINT 'DA THEM VAO BANG CTHD'
	END
END


CREATE TRIGGER TR_XOATRONGVIEWS
ON ABC INSTEAD OF DELETE
AS
BEGIN	
	IF EXISTS(SELECT MASP FROM deleted)
	BEGIN
		DELETE FROM CTHD
		WHERE SOHD = (SELECT SOHD FROM deleted)
		AND MASP = (SELECT MASP FROM deleted)
		PRINT 'DA XOA VAO BANG CTHD'
	END
END


CREATE TRIGGER TR_SUATRONGVIEWS
ON ABC INSTEAD OF UPDATE
AS
BEGIN
	IF EXISTS(SELECT MASP FROM inserted)
	BEGIN
		UPDATE CTHD
		SET SL = (SELECT SL FROM inserted)
		WHERE SOHD = (SELECT SOHD FROM inserted)
		AND MASP = (SELECT MASP FROM inserted)

		PRINT 'DA SUA VAO BANG CTHD'
	END
END