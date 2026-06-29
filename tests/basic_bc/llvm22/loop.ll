; ModuleID = 'loop.c'
source_filename = "loop.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: nofree norecurse nounwind ssp memory(inaccessiblemem: readwrite) uwtable(sync)
define void @loop(i32 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = alloca [10 x i32], align 4
  call void @llvm.lifetime.start.p0(ptr nonnull %3) #4
  call void @llvm.memset.p0.i64(ptr nonnull align 4 %3, i8 0, i64 40, i1 true)
  %4 = add i32 %1, -1
  %5 = icmp ult i32 %4, 10
  br i1 %5, label %6, label %39

6:                                                ; preds = %2
  %7 = add nsw i32 %0, 3
  store volatile i32 %7, ptr %3, align 4, !tbaa !6
  %8 = icmp eq i32 %1, 1
  br i1 %8, label %39, label %9

9:                                                ; preds = %6
  %10 = zext nneg i32 %1 to i64
  %11 = add nsw i64 %10, -1
  %12 = and i64 %11, 1
  %13 = icmp eq i32 %1, 2
  br i1 %13, label %32, label %14

14:                                               ; preds = %9
  %15 = and i64 %11, -2
  br label %16

16:                                               ; preds = %16, %14
  %17 = phi i64 [ 1, %14 ], [ %27, %16 ]
  %18 = phi i64 [ 0, %14 ], [ %28, %16 ]
  %19 = getelementptr inbounds nuw i32, ptr %3, i64 %17
  store volatile i32 %7, ptr %19, align 4, !tbaa !6
  %20 = getelementptr i8, ptr %19, i64 -4
  %21 = load volatile i32, ptr %20, align 4, !tbaa !6
  %22 = add nsw i32 %21, %1
  store volatile i32 %22, ptr %20, align 4, !tbaa !6
  %23 = getelementptr inbounds nuw i32, ptr %3, i64 %17
  %24 = getelementptr inbounds nuw i8, ptr %23, i64 4
  store volatile i32 %7, ptr %24, align 4, !tbaa !6
  %25 = load volatile i32, ptr %23, align 4, !tbaa !6
  %26 = add nsw i32 %25, %1
  store volatile i32 %26, ptr %23, align 4, !tbaa !6
  %27 = add nuw nsw i64 %17, 2
  %28 = add i64 %18, 2
  %29 = icmp eq i64 %28, %15
  br i1 %29, label %30, label %16, !llvm.loop !10

30:                                               ; preds = %16
  %31 = icmp eq i64 %12, 0
  br i1 %31, label %39, label %32

32:                                               ; preds = %30, %9
  %33 = phi i64 [ 1, %9 ], [ %27, %30 ]
  %34 = icmp ne i64 %12, 0
  tail call void @llvm.assume(i1 %34)
  %35 = getelementptr inbounds nuw i32, ptr %3, i64 %33
  store volatile i32 %7, ptr %35, align 4, !tbaa !6
  %36 = getelementptr i8, ptr %35, i64 -4
  %37 = load volatile i32, ptr %36, align 4, !tbaa !6
  %38 = add nsw i32 %37, %1
  store volatile i32 %38, ptr %36, align 4, !tbaa !6
  br label %39

39:                                               ; preds = %32, %30, %6, %2
  call void @llvm.lifetime.end.p0(ptr nonnull %3) #4
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #3

attributes #0 = { nofree norecurse nounwind ssp memory(inaccessiblemem: readwrite) uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #3 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}
!llvm.errno.tbaa = !{!6}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 2]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 4}
!5 = !{!"Homebrew clang version 22.1.4"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = distinct !{!10, !11, !12}
!11 = !{!"llvm.loop.mustprogress"}
!12 = !{!"llvm.loop.peeled.count", i32 1}
