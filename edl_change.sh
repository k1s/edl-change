#!/bin/sh
exec scala "$0" "$@"
!#
object HelloWorld {

import java.nio.file.{Paths, Files, StandardOpenOption}
import scala.util.matching.Regex
import language.postfixOps
import scala.collection.JavaConverters._

val sourceFilesPattern = "(?<=SOURCE FILE: )(.*$)".r()
val clipNamesPattern = "(?<=CLIP NAME: )(.*$)".r()
val reelNamesPattern = "(?<=0[0-9][0-9]\\s)(.*)(?=\\s(V|B)\\s)"

def fromPattern(pattern: Regex): List[String] = {
  fileLines map (pattern findFirstIn(_).trim) flatten
}
    
  def main(args: Array[String]) {

    if (args.isEmpty) {
      println("Usage: edl_change.sh file_to_copy.edl")
      System.exit(-1);
    }

    val filename = args(0)
    val inputLines = io.Source.fromFile(filename).getLines().toList
    val fileLines = inputLines filter (line => !(line contains " BL "))
    val reelLines = fileLines filter (line => line matches "(0[0-9][0-9]\\s.*)")

    val fromComments = fromPattern(sourceFilesPattern) ++ fromPattern(clipNamesPattern)

    if (reelLines.size != fromComments.size)
       println("Reel names count differs from comments count \n" +
               "but they must be the same. Looks like smth is wrong \n")

    val result = reelLines zip fromComments map {
      case (reel, comment) => reel replaceAll(reelNamesPattern, comment)
    }

    val path = Paths.get(filename.replaceAll("(.edl|.EDL)", "") + "_copy.edl")
    Files.write(path, result.asJava, StandardOpenOption.CREATE)

}
}

HelloWorld.main(args)
