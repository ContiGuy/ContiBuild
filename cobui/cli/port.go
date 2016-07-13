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
	"net/http"
	"net/http/httptest"
	"os"
	"strings"

	"github.com/spf13/cobra"
	"github.com/toqueteos/webbrowser"
)

var (
	// portCmd represents the port command
	portCmd = &cobra.Command{
		Use:   "port",
		Short: "A brief description of your command",
		Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
		//		Run: func(cmd *cobra.Command, args []string) {
		//			// TODO: Work your own magic here
		//			fmt.Println("port called")
		//		},
		RunE: openPorts,
	}
)

func init() {
	RootCmd.AddCommand(portCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// portCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// portCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")

}

func openPorts(cmd *cobra.Command, args []string) error {
	// TODO: Work your own magic here
	//	fmt.Println("port called")
	if len(args) == 0 {
		return errors.New("missing port argument list")
	}

	portMappings_l := make([]string, 0, len(args)+2)
	for _, port_s := range args {
		srv := httptest.NewServer(http.HandlerFunc( //--"/",
			func(w http.ResponseWriter, r *http.Request) {
				fmt.Fprintf(os.Stderr, "%+v\n", *r)
				http.Error(w, "temp server", http.StatusNotImplemented)
			}))
		srvUrlLen := len(srv.URL)
		colonIdx := strings.LastIndex(srv.URL, ":")
		localPort_s := srv.URL[colonIdx+1 : srvUrlLen]
		portMappings_l = append(portMappings_l, localPort_s+":"+port_s)
		webbrowser.Open(srv.URL)
	}
	fmt.Printf("-p %s\n", strings.Join(portMappings_l, " -p "))
	return nil
}
