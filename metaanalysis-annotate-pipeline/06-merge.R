args <- commandArgs(trailingOnly = TRUE)
posfn = args[1]
annfn = args[2]
outfn = args[3]

print(paste("merge", posfn, annfn, outfn))

data = read.table(posfn, h=T)
names(data)[1] = "Chr";
names(data)[2] = "Start";
names(data)[3] = "End";
names(data)[4] = "Ref";
names(data)[5] = "Alt";
head(data)

anno = read.table(annfn, h=T, sep="\t")
head(anno)

result = merge(data, anno)
dim(data)
dim(anno)
dim(result)

result = result[order(result$p.value),]
write.table(result, outfn, row.names=F, col.names=T, quote=T, sep=";", dec=".")
