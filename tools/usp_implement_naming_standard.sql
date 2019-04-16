SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

ALTER PROCEDURE XtrlUtils.usp_implement_naming_standard
(
    @primaryKeys BIT = 1,
    @foreignKeys BIT = 1,
    @indexes BIT = 1,
    @columnStoreIndexes BIT = 1,
    @clusteredColumnStoreIndexes BIT = 1,
    @uniqueConstraints BIT = 1,
    @defaultConstraints BIT = 1,
    @checkConstraints BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql VARCHAR(MAX) = '';
    DECLARE @cr CHAR(2) = CHAR(13) + CHAR(10);
    DECLARE @TableLimit TINYINT = 255;
    DECLARE @ColumnLimit TINYINT = 255;

    IF @primaryKeys = 1
    BEGIN

        SELECT N'/* ---- Primary Keys ---- */';

        SELECT N'EXEC sp_rename @objname = N''' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + '.' + QUOTENAME(kc.name) + ''', @newname = N''PK_'
               + LEFT(REPLACE(t.name, '''', ''), @TableLimit) + ''', @objtype=''INDEX'';'
        FROM   sys.key_constraints AS kc
               INNER JOIN sys.tables t ON kc.parent_object_id = t.object_id
               INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE  kc.type = 'PK'
               AND kc.is_ms_shipped = 0
               AND kc.name <> N'PK_' + LEFT(REPLACE(t.name, '''', ''), @TableLimit);

    END;


    IF @foreignKeys = 1
    BEGIN
        SELECT N'/* ---- Foreign Keys ---- */';

        SELECT N'EXEC sp_rename @objname = N''' + REPLACE(CONCAT(QUOTENAME(s.name), '.', QUOTENAME(f.name)), '''', '''''') + ''', @newname = N''FK_'
               + LEFT(REPLACE(OBJECT_NAME(f.parent_object_id), '''', ''), @TableLimit) + '_'
               + LEFT(REPLACE(OBJECT_NAME(f.referenced_object_id), '''', ''), @TableLimit) + '_'
               + LEFT(REPLACE(COL_NAME(k.parent_object_id, k.parent_column_id), '''', ''), @TableLimit) + ''';'
        FROM   sys.foreign_keys f
               INNER JOIN sys.foreign_key_columns k ON k.constraint_object_id = f.object_id
               INNER JOIN sys.tables p ON p.object_id = f.parent_object_id
               INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
        WHERE  f.is_ms_shipped = 0
               AND f.name <> N'FK_' + LEFT(REPLACE(OBJECT_NAME(f.parent_object_id), '''', ''), @TableLimit) + '_'
                             + LEFT(REPLACE(OBJECT_NAME(f.referenced_object_id), '''', ''), @TableLimit) + '_'
                             + LEFT(REPLACE(COL_NAME(k.parent_object_id, k.parent_column_id), '''', ''), @TableLimit);
    END;

    IF (@indexes = 1)
    BEGIN

        SELECT N'/* ---- Indexes ---- */';

        SELECT   N'EXEC sp_rename @objname = N''' + IDX.FullyQualifiedIndexName + ''', @newname = N''' + IDX.NewIndexName + ''';'
        FROM     (   SELECT QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + '.' + CASE is_unique_constraint
                                                                                    WHEN 0 THEN REPLACE(QUOTENAME(OBJECT_NAME(i.object_id)), '''', '''''') + '.'
                                                                                    ELSE ''
                                                                               END + REPLACE(QUOTENAME(i.name), '''', '''''') AS FullyQualifiedIndexName,
                            i.name AS CurrentIndexName,
                            CASE is_unique_constraint
                                 WHEN 1 THEN 'UQ_'
                                 ELSE 'IX_' + CASE is_unique
                                                   WHEN 1 THEN 'U_'
                                                   ELSE ''
                                              END
                            END + CASE has_filter
                                       WHEN 1 THEN 'F_'
                                       ELSE ''
                                  END + LEFT(REPLACE(OBJECT_NAME(i.object_id), '''', ''), @TableLimit) + '_'
                            + STUFF((   SELECT   '_' + LEFT(REPLACE(c.name, '''', ''), @ColumnLimit)
                                        FROM     sys.columns AS c
                                                 INNER JOIN sys.index_columns AS ic ON ic.column_id = c.column_id
                                                                                       AND ic.object_id = c.object_id
                                        WHERE    ic.object_id = i.object_id
                                                 AND ic.index_id = i.index_id
                                                 AND is_included_column = 0
                                        ORDER BY ic.index_column_id
                                        FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '') + CASE
                                                                                                              WHEN i.filter_definition IS NOT NULL THEN '_'
                                                                                                              ELSE ''
                                                                                                         END
                            + CASE
                                   WHEN EXISTS (   SELECT c.object_id
                                                   FROM   sys.columns AS c
                                                          INNER JOIN sys.index_columns AS ic ON ic.column_id = c.column_id
                                                                                                AND ic.object_id = c.object_id
                                                   WHERE  ic.object_id = i.object_id
                                                          AND ic.index_id = i.index_id
                                                          AND is_included_column = 1) THEN
                                   '_INC_' + STUFF((   SELECT   TOP 3
                                                                '_' + LEFT(REPLACE(c.name, '''', ''), @ColumnLimit)
                                                       FROM     sys.columns AS c
                                                                INNER JOIN sys.index_columns AS ic ON ic.column_id = c.column_id
                                                                                                      AND ic.object_id = c.object_id
                                                       WHERE    ic.object_id = i.object_id
                                                                AND ic.index_id = i.index_id
                                                                AND is_included_column = 1
                                                       ORDER BY ic.index_column_id
                                                       FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '')
                                   ELSE ''
                              END
                            + ISNULL(
                                  REPLACE(
                                      REPLACE(
                                          REPLACE(
                                              REPLACE(
                                                  REPLACE(
                                                      REPLACE(
                                                          REPLACE(REPLACE(REPLACE(REPLACE(i.filter_definition, 'IS ', ''), '''', ''), '=', '_EQ_'), '<', '_LT_'),
                                                          '>', '_GT_'), ' ', '_'), ')', ''), '(', ''), '[', ''), ']', ''), '') AS NewIndexName
                     FROM   sys.indexes AS i
                     WHERE  index_id > 0
                            AND is_primary_key = 0
                            AND type IN (1, 2)
                            AND OBJECTPROPERTY(i.object_id, 'IsMsShipped') = 0
                            AND i.is_unique_constraint = 0) AS IDX
        WHERE    IDX.CurrentIndexName <> IDX.NewIndexName
        ORDER BY IDX.NewIndexName;

    END;

    IF (@columnStoreIndexes = 1)
    BEGIN

        SELECT N'/* ---- ColumnStore Indexes ---- */';

        SELECT N'EXEC sp_rename @objname = N''' + IDX.FullyQualifiedIndexName + ''', @newname = N''' + IDX.NewIndexName + ''';'
        FROM   (   SELECT QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + '.' + CASE is_unique_constraint
                                                                                  WHEN 0 THEN REPLACE(QUOTENAME(OBJECT_NAME(i.object_id)), '''', '''''') + '.'
                                                                                  ELSE ''
                                                                             END + REPLACE(QUOTENAME(i.name), '''', '''''') AS FullyQualifiedIndexName,
                          i.name AS CurrentIndexName,
                          CASE is_unique_constraint
                               WHEN 1 THEN 'UQ_'
                               ELSE 'IX_' + CASE is_unique
                                                 WHEN 1 THEN 'U_'
                                                 ELSE ''
                                            END
                          END + CASE has_filter
                                     WHEN 1 THEN 'F_'
                                     ELSE ''
                                END + LEFT(REPLACE(OBJECT_NAME(i.object_id), '''', ''), @TableLimit) + '_'
                          + STUFF((   SELECT   '_' + LEFT(REPLACE(c.name, '''', ''), @ColumnLimit)
                                      FROM     sys.columns AS c
                                               INNER JOIN sys.index_columns AS ic ON ic.column_id = c.column_id
                                                                                     AND ic.object_id = c.object_id
                                      WHERE    ic.object_id = i.object_id
                                               AND ic.index_id = i.index_id
                                               AND is_included_column = 0
                                      ORDER BY ic.index_column_id
                                      FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '') + CASE
                                                                                                            WHEN i.filter_definition IS NOT NULL THEN '_'
                                                                                                            ELSE ''
                                                                                                       END
                          + ISNULL(
                                REPLACE(
                                    REPLACE(
                                        REPLACE(
                                            REPLACE(
                                                REPLACE(
                                                    REPLACE(
                                                        REPLACE(REPLACE(REPLACE(REPLACE(i.filter_definition, 'IS ', ''), '''', ''), '=', '_EQ_'), '<', '_LT_'),
                                                        '>', '_GT_'), ' ', '_'), ')', ''), '(', ''), '[', ''), ']', ''), '') AS NewIndexName
                   FROM   sys.indexes AS i
                   WHERE  is_hypothetical = 0
                          AND i.index_id <> 0
                          AND i.type_desc IN ('NONCLUSTERED COLUMNSTORE')) AS IDX
        WHERE  IDX.CurrentIndexName <> IDX.NewIndexName;

    END;


    IF (@clusteredColumnStoreIndexes = 1)
    BEGIN

        SELECT N'/* ---- Clustered ColumnStore Indexes ---- */';

        SELECT N'EXEC sp_rename @objname = N''' + IDX.FullyQualifiedIndexName + ''', @newname = N''' + IDX.NewIndexName + ''';'
        FROM   (   SELECT QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + '.' + CASE is_unique_constraint
                                                                                  WHEN 0 THEN REPLACE(QUOTENAME(OBJECT_NAME(i.object_id)), '''', '''''') + '.'
                                                                                  ELSE ''
                                                                             END + REPLACE(QUOTENAME(i.name), '''', '''''') AS FullyQualifiedIndexName,
                          i.name AS CurrentIndexName,
                          'CCIX_' + OBJECT_SCHEMA_NAME(object_id) + '_' + OBJECT_NAME(object_id) AS NewIndexName
                   FROM   sys.indexes AS i
                   WHERE  is_hypothetical = 0
                          AND i.index_id <> 0
                          AND i.type_desc IN ('CLUSTERED COLUMNSTORE')) AS IDX
        WHERE  IDX.CurrentIndexName <> IDX.NewIndexName;

    END;

    IF (@uniqueConstraints = 1)
    BEGIN

        SELECT N'/* Unique Constraints ---- */';

        SELECT N'EXEC sp_rename @objname = N''' + IDX.FullyQualifiedIndexName + ''', @newname = N''' + IDX.NewIndexName + ''';'
        FROM   (   SELECT QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)) + '.' + CASE is_unique_constraint
                                                                                  WHEN 0 THEN REPLACE(QUOTENAME(OBJECT_NAME(i.object_id)), '''', '''''') + '.'
                                                                                  ELSE ''
                                                                             END + REPLACE(QUOTENAME(i.name), '''', '''''') AS FullyQualifiedIndexName,
                          i.name AS CurrentIndexName,
                          CASE is_unique_constraint
                               WHEN 1 THEN 'UQ_'
                               ELSE 'IX_' + CASE is_unique
                                                 WHEN 1 THEN 'U_'
                                                 ELSE ''
                                            END
                          END + CASE has_filter
                                     WHEN 1 THEN 'F_'
                                     ELSE ''
                                END + LEFT(REPLACE(OBJECT_NAME(i.object_id), '''', ''), @TableLimit) + '_'
                          + STUFF((   SELECT   '_' + LEFT(REPLACE(c.name, '''', ''), @ColumnLimit)
                                      FROM     sys.columns AS c
                                               INNER JOIN sys.index_columns AS ic ON ic.column_id = c.column_id
                                                                                     AND ic.object_id = c.object_id
                                      WHERE    ic.object_id = i.object_id
                                               AND ic.index_id = i.index_id
                                               AND is_included_column = 0
                                      ORDER BY ic.index_column_id
                                      FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '') + CASE
                                                                                                            WHEN i.filter_definition IS NOT NULL THEN '_'
                                                                                                            ELSE ''
                                                                                                       END
                          + ISNULL(
                                REPLACE(
                                    REPLACE(
                                        REPLACE(
                                            REPLACE(
                                                REPLACE(
                                                    REPLACE(
                                                        REPLACE(REPLACE(REPLACE(REPLACE(i.filter_definition, 'IS ', ''), '''', ''), '=', '_EQ_'), '<', '_LT_'),
                                                        '>', '_GT_'), ' ', '_'), ')', ''), '(', ''), '[', ''), ']', ''), '') AS NewIndexName
                   FROM   sys.indexes AS i
                   WHERE  index_id > 0
                          AND is_primary_key = 0
                          AND type IN (1, 2)
                          AND OBJECTPROPERTY(i.object_id, 'IsMsShipped') = 0
                          AND i.is_unique_constraint = 1) AS IDX
        WHERE  IDX.CurrentIndexName <> IDX.NewIndexName;

    END;

    IF @defaultConstraints = 1
    BEGIN
        SELECT N'/* ---- DefaultConstraints ---- */';
        SELECT N'EXEC sp_rename @objname = N''' + QUOTENAME(OBJECT_SCHEMA_NAME(dc.parent_object_id)) + '.' + REPLACE(QUOTENAME(dc.name), '''', '''''')
               + ''', @newname = N''DF_' + LEFT(REPLACE(OBJECT_NAME(dc.parent_object_id), '''', ''), @TableLimit) + '_'
               + LEFT(REPLACE(c.name, '''', ''), @ColumnLimit) + ''';'
        FROM   sys.default_constraints AS dc
               INNER JOIN sys.columns AS c ON dc.parent_object_id = c.object_id
                                              AND dc.parent_column_id = c.column_id
                                              AND dc.is_ms_shipped = 0
        WHERE  dc.name <> N'DF_' + LEFT(REPLACE(OBJECT_NAME(dc.parent_object_id), '''', ''), @TableLimit) + '_' + LEFT(REPLACE(c.name, '''', ''), @ColumnLimit);
    END;


    IF @checkConstraints = 1
    BEGIN
        SELECT N'/* ---- CheckConstraints ---- */';

        SELECT N'EXEC sp_rename @objname = N''' + QUOTENAME(OBJECT_SCHEMA_NAME(cc.parent_object_id)) + '.' + REPLACE(QUOTENAME(cc.name), '''', '''''')
               + ''', @newname = N''CK_' + LEFT(REPLACE(OBJECT_NAME(cc.parent_object_id), '''', ''), @TableLimit) + '_'
               + LEFT(REPLACE(c.name, '''', ''), @ColumnLimit) + ''';'
        FROM   sys.check_constraints AS cc
               INNER JOIN sys.columns AS c ON cc.parent_object_id = c.object_id
                                              AND cc.parent_column_id = c.column_id
                                              AND cc.is_ms_shipped = 0
        WHERE  cc.name <> N'CK_' + LEFT(REPLACE(OBJECT_NAME(cc.parent_object_id), '''', ''), @TableLimit) + '_' + LEFT(REPLACE(c.name, '''', ''), @ColumnLimit);
    END;

END;



GO

