// Perform:
// SELECT COUNT(*) FROM all_types
//  WHERE bool_col = true
//    AND (tinyint_col >= 0 OR smallint_col >= 0 OR int_col >=0 OR bigint_col >= 0)
//
// Should output 500 because half of the bool_col values will be true
// The goal of this test is to make sure that we support all of the primitive
// types in the TPL language.

fun main(execCtx: *ExecutionContext) -> int64 {
  var ret = 0
  var tvi: TableVectorIterator
  var oids: [5]uint32
  oids[0] = 1 // bool_col
  oids[1] = 2 // tinyint_col
  oids[2] = 3 // smallint_col
  oids[3] = 4 // int_col
  oids[4] = 5 // bigint_col

  @tableIterInitBind(&tvi, execCtx, "all_types", oids)
  for (@tableIterAdvance(&tvi)) {
    var pci = @tableIterGetPCI(&tvi)
    for (; @pciHasNext(pci); @pciAdvance(pci)) {
      var col0 = @pciGetBool(pci, 3)
      var col1 = @pciGetTinyInt(pci, 4)
      var col2 = @pciGetSmallInt(pci, 2)
      var col3 = @pciGetInt(pci, 1)
      var col4 = @pciGetBigInt(pci, 0)

      if (col0 == true) { 
          // and 
          // (col1 >= 0 or col2 >= 0 or col3 >= 0 or col4 >= 0)) {
        ret = ret + 1
      }
    }
    @pciReset(pci)
  }
  @tableIterClose(&tvi)
  return ret
}

