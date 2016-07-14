// Copyright © 2016 NAME HERE <EMAIL ADDRESS>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package cli

import (
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
	"github.com/yookoala/realpath"
)

var (
	// gopathCmd represents the gopath command
	gopathCmd = &cobra.Command{
		Use:   "gopath",
		Short: "split the current working directory into a base part found in $GOPATH and a go package name",
		Long:  `Split the current working directory into a base part found in $GOPATH and a go package name.`,
		RunE:  cmdGoPath,
	}

	//	base  = gopathCmd.Flags().BoolP("base", "b", false, "return the base part of $CWD found in $GOPATH")
	//	pkg   = gopathCmd.Flags().BoolP("package", "p", false, "return the go package name of $CWD not found in $GOPATH")
	//	debug = gopathCmd.Flags().BoolP("debug", "d", false, "print some debug log messages")
	base, pkg, debug *bool
)

func init() {
	RootCmd.AddCommand(gopathCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// gopathCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// gopathCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")

	base = gopathCmd.Flags().BoolP("base", "b", false, "return the base part of $CWD found in $GOPATH")
	pkg = gopathCmd.Flags().BoolP("package", "p", false, "return the go package name of $CWD not found in $GOPATH")
	debug = gopathCmd.Flags().BoolP("debug", "d", false, "print some debug log messages")
}

func cmdGoPath(cmd *cobra.Command, args []string) error {
	//	flag.Parse()
	gp, err := splitGoPath()
	//	if len(gp) == 0 {
	if err != nil {
		//		os.Exit(42)
		return err
	}
	if *base {
		fmt.Println(gp[0])
		return nil
	}
	if *pkg {
		if len(gp) < 2 {
			//			fmt.Fprintln(os.Stderr, "must be in a subfolder of $GOPATH/src to get a valid go package name")
			errMsg := fmt.Sprint("must be in a subfolder of $GOPATH/src to get a valid go package name")
			//			os.Exit(43)
			return errors.New(errMsg)
		}
		fmt.Println(gp[1])
		return nil
	}
	//	fmt.Fprintln(os.Stderr, "usage: gopath (-base|-package) [options]")
	errMsg := fmt.Sprint("need at least either --base or --package option")
	return errors.New(errMsg)
	//	flag.Usage()
	//	os.Exit(41)
}

func splitGoPath() ([]string, error) {
	goPath_s := os.Getenv("GOPATH")
	if goPath_s == "" {
		//		fmt.Fprintln(os.Stderr, "GOPATH env var must be set")
		errMsg := fmt.Sprint("GOPATH environment variable must be set")
		return nil, errors.New(errMsg)
	}

	var err error
	wd := [3]string{}
	//	rwd, err := os.Getwd()
	wd[0], err = os.Getwd()
	if err != nil {
		panic(err)
	}
	//	xwd, err := filepath.Abs(rwd)
	wd[1], err = filepath.Abs(wd[0])
	if err != nil {
		panic(err)
	}
	//	awd, err := realpath.Realpath(xwd)
	wd[2], err = realpath.Realpath(wd[1])
	if err != nil {
		panic(err)
	}

	ret := make([]string, 0, 2)
	goPath := ""
	goPath_l := strings.Split(goPath_s, ":")
	awd := ""
gopathLoop:
	for _, goPath = range goPath_l {
		goPathPrefix := filepath.Join(goPath, "src")
		for i := range wd {
			//			if strings.HasPrefix(awd, goPathPrefix) {
			if strings.HasPrefix(wd[i], goPathPrefix) {
				if *debug {
					log.Printf("gopath='%s'\n", goPath)
				}
				ret = append(ret, goPath)
				awd = wd[i]
				break gopathLoop
			}
		}
	}
	if *debug {
		log.Printf("wd=%q, awd='%s', gopaths=%q, goPath='%s', len(goPath)=%d\n",
			wd, awd, goPath_l, goPath, len(goPath))
		//		log.Printf("wd='%s', awd='%s', len(awd)=%d, goPath='%s', len(goPath)=%d\n",
		//			rwd, awd, len(awd), goPath, len(goPath))
	}

	if len(ret) == 0 {
		//		fmt.Fprintln(os.Stderr, "not in a subfolder of $GOPATH/src")
		errMsg := fmt.Sprint("not in a subfolder of $GOPATH/src")
		return nil, errors.New(errMsg)
	}
	goPathBaseLen := len(goPath) + 1 + 4
	if len(awd) <= goPathBaseLen {
		//		fmt.Fprintln(os.Stderr, "not in a subfolder of $GOPATH/src")
		//		return ret
		errMsg := fmt.Sprint("not in a subfolder of $GOPATH/src")
		return ret, errors.New(errMsg)
	}

	goPkg := awd[goPathBaseLen:]
	ret = append(ret, goPkg)
	return ret, nil
}
