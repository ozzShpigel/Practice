using Microsoft.VisualStudio.TestTools.UnitTesting;
using OzTest;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OzUnitTest
{
    [TestClass]
    public class CalcTest
    {
        [TestMethod]
        public void Add()
        {
            var sut = new Calculator();
            var result = sut.Add(1, 3);
            Assert.AreEqual(4, result);
        }
    }
}
